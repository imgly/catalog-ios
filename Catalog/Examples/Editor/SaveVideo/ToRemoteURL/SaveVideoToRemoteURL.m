#import "SaveVideoToRemoteURL.h"
@import VideoEditorSDK;

@interface SaveVideoToRemoteURLObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation SaveVideoToRemoteURLObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  // highlight-setup
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
  videoEditViewController.delegate = self;
  videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
  // highlight-setup
}

#pragma mark - PESDKVideoEditViewControllerDelegate

- (BOOL)videoEditViewControllerShouldStart:(PESDKVideoEditViewController * _Nonnull)videoEditViewController task:(PESDKVideoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

// highlight-video-export-delegate
 - (void)videoEditViewControllerDidFinish:(PESDKVideoEditViewController * _Nonnull)videoEditViewController result:(PESDKVideoEditorResult * _Nonnull)result {
  // highlight-video-export-delegate
  // The user exported a new video successfully and the newly generated video is located at `result.output.url`.
  // If **no modifications** have been made to the original video, we will not process the original video at all
  // and also not reencode it. In this case `result.output.url` will point to the original video that was passed to the editor,
  // if available. If you want to ensure that the original video is always reencoded, even if no modifications have
  // been made to it, you can set `PESDKVideoEditViewControllerOptions.forceExport` to `YES`, in which case `result.output.url` will
  // always point to a newly generated video.

  // Create an `NSURLRequest` object for the web service that will receive this upload. This example doesn't use a valid
  // URL and the request will fail.
  // highlight-create-request
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost/fileupload"]];
  // Most web services will expect the 'POST' HTTP method for file uploads.
  urlRequest.HTTPMethod = @"POST";
  // highlight-create-request

  // Create the upload task.
  // highlight-upload
  NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:urlRequest fromFile:result.output.url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"The file upload failed: %@", error.description);
    }

    if (response != nil) {
      NSLog(@"The server replied with status code %ld", (long)((NSHTTPURLResponse *)response).statusCode);
    }

    if (data != nil) {
      NSLog(@"Received a %lu byte answer from the server.", data.length);
    }

    // Remove the video when done uploading. If the video was passed without rendering, we won't delete the file.
    // In production this check would not be needed because the app bundle is read-only.
    // Unfortunately, with the Simulator it is not read-only so we need to include this check
    // or the example will crash when opened a second time.
    if (result.status != VESDKVideoEditorStatusPassedWithoutRendering) {
      [[NSFileManager defaultManager] removeItemAtURL:result.output.url error:nil];
    }
  }];
  // highlight-upload

  // Start the upload task. This will run in the background, so the view controller can be dismissed immediately.
  // highlight-background
  [uploadTask resume];
  // highlight-background
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoEditViewControllerDidFail:(PESDKVideoEditViewController * _Nonnull)videoEditViewController error:(PESDKVideoEditorError * _Nonnull)error {
  // There was an error generating the video.
  NSLog(@"%@", error.localizedDescription);
  // Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoEditViewControllerDidCancel:(PESDKVideoEditViewController * _Nonnull)videoEditViewController {
  // The user tapped on the cancel button within the editor. Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
