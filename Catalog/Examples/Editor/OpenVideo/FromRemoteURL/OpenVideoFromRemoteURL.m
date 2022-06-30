#import "OpenVideoFromRemoteURL.h"
@import VideoEditorSDK;

@interface OpenVideoFromRemoteURLObjC () <PESDKVideoEditViewControllerDelegate>

@property (nonatomic, nullable, strong) NSURL *localURL;

@end

@implementation OpenVideoFromRemoteURLObjC

- (void)invokeExample {
  // Although the editor supports opening a remote URL, we highly recommend
  // that you manage the download of the remote resource yourself, since this
  // gives you more control over the whole process. After successfully downloading
  // the file you should pass a local URL to the downloaded video to the editor.
  // This example demonstrates how to achieve this.
  NSURL *remoteURL = [NSURL URLWithString:@"https://img.ly/static/example-assets/Skater.mp4"];

  // highlight-download
  NSURLSessionDownloadTask *downloadTask = [NSURLSession.sharedSession downloadTaskWithURL:remoteURL completionHandler:^(NSURL * _Nullable downloadURL, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error != nil) {
      [NSException raise:@"Error downloading file" format:@"There was an error downloading the file: %@", error.description];
      return;
    }

    if (downloadURL != nil) {
      // File was downloaded successfully. Saving it in the temporary directory.
      NSURL *temporaryDirectoryURL = NSFileManager.defaultManager.temporaryDirectory;
      NSURL *localURL = [temporaryDirectoryURL URLByAppendingPathComponent:remoteURL.lastPathComponent];

      if ([NSFileManager.defaultManager fileExistsAtPath:localURL.path]) {
        // Remove the file at the destination if it already exists
        [NSFileManager.defaultManager removeItemAtURL:localURL error:nil];
      }

      [NSFileManager.defaultManager moveItemAtURL:downloadURL toURL:localURL error:nil];
      self.localURL = localURL;
      // highlight-download

      // Dispatch to the main queue for any UI work
      // highlight-instantiation
      dispatch_async(dispatch_get_main_queue(), ^{
        // Create a `PESDKVideo` from the local file URL.
        PESDKVideo *video = [[PESDKVideo alloc] initWithURL:localURL];

        // Create a default `PESDKConfiguration`.
        PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

        // Create a video editor and pass it the video and configuration. Make this class the delegate of it to handle export and cancelation.
        PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
        videoEditViewController.delegate = self;
        // highlight-instantiation

        // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
        // highlight-user-interaction
        self.presentingViewController.view.userInteractionEnabled = YES;

        // Present the video editor.
        videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
      });
    }
  }];

  // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
  self.presentingViewController.view.userInteractionEnabled = NO;
  // highlight-user-interaction

  // Start the file download
  [downloadTask resume];
}

#pragma mark - PESDKVideoEditViewControllerDelegate

- (BOOL)videoEditViewControllerShouldStart:(PESDKVideoEditViewController * _Nonnull)videoEditViewController task:(PESDKVideoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

 - (void)videoEditViewControllerDidFinish:(PESDKVideoEditViewController * _Nonnull)videoEditViewController result:(PESDKVideoEditorResult * _Nonnull)result {
  // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor
  // and removing the downloaded file.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [NSFileManager.defaultManager removeItemAtURL:self.localURL error:nil];
  }];
}

- (void)videoEditViewControllerDidFail:(PESDKVideoEditViewController * _Nonnull)videoEditViewController error:(PESDKVideoEditorError * _Nonnull)error {
  // There was an error generating the video.
  NSLog(@"%@", error.localizedDescription);
  // Dismissing the editor and removing the downloaded file.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [NSFileManager.defaultManager removeItemAtURL:self.localURL error:nil];
  }];
}

- (void)videoEditViewControllerDidCancel:(PESDKVideoEditViewController * _Nonnull)videoEditViewController {
  // The user tapped the cancel button. Dismissing the editor and removing the downloaded file.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [NSFileManager.defaultManager removeItemAtURL:self.localURL error:nil];
  }];
}


@end
