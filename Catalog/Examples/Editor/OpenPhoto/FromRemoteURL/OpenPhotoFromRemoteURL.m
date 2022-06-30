#import "OpenPhotoFromRemoteURL.h"
@import PhotoEditorSDK;

@interface OpenPhotoFromRemoteURLObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation OpenPhotoFromRemoteURLObjC

- (void)invokeExample {
  // Although the editor supports opening a remote URL, we highly recommend
  // that you manage the download of the remote resource yourself, since this
  // gives you more control over the whole process. After successfully downloading
  // the file you should pass a `Data` object or a local URL to the downloaded photo
  // to the editor. This example demonstrates how to achieve the former.
  NSURL *remoteURL = [NSURL URLWithString:@"https://img.ly/static/example-assets/LA.jpg"];

  // highlight-download
  NSURLSessionDownloadTask *downloadTask = [NSURLSession.sharedSession downloadTaskWithURL:remoteURL completionHandler:^(NSURL * _Nullable downloadURL, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error != nil) {
      [NSException raise:@"Error downloading file" format:@"There was an error downloading the file: %@", error.description];
      return;
    }

    if (downloadURL != nil) {
      // File was downloaded successfully. Creating an `NSData` object from it.
      // To save memory you can also save the file to disk instead of keeping it in memory.
      // For an example on how to do this, see `OpenVideoFromRemoteURLObjC`.
      NSData *imageData = [NSData dataWithContentsOfURL:downloadURL];
      // highlight-download

      // Dispatch to the main queue for any UI work.
      // highlight-instantiation
      dispatch_async(dispatch_get_main_queue(), ^{
        // Create a `PESDKPhoto` from the `NSData` object.
        PESDKPhoto *photo = [[PESDKPhoto alloc] initWithData:imageData];

        // Create a default `PESDKConfiguration`.
        PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

        // Create a photo editor and pass it the photo and configuration. Make this class the delegate of it to handle export and cancelation.
        PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration];
        photoEditViewController.delegate = self;
        // highlight-instantiation

        // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
        // highlight-user-interaction
        self.presentingViewController.view.userInteractionEnabled = YES;

        // Present the photo editor.
        photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];
      });
    }
  }];

  // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
  self.presentingViewController.view.userInteractionEnabled = NO;
  // highlight-user-interaction

  // Start the file download
  [downloadTask resume];
}

#pragma mark - PESDKPhotoEditViewControllerDelegate

- (BOOL)photoEditViewControllerShouldStart:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController task:(PESDKPhotoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

- (void)photoEditViewControllerDidFinish:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController result:(PESDKPhotoEditorResult * _Nonnull)result {
  // The image has been exported successfully and is passed as an `NSData` object in the `result.output.data`.
  // To create an `UIImage` from the output, use `[UIImage initWithData:]`.
  // See other examples about how to save the resulting image.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidFail:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController error:(PESDKPhotoEditorError * _Nonnull)error {
  // There was an error generating the photo.
  NSLog(@"%@", error.localizedDescription);
  // Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditViewControllerDidCancel:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController {
  // The user tapped on the cancel button within the editor. Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
