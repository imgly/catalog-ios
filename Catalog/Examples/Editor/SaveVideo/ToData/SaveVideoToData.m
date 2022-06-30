#import "SaveVideoToData.h"
@import VideoEditorSDK;

@interface SaveVideoToDataObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation SaveVideoToDataObjC

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
  
  // Load file into memory. This could fail for large videos.
  // In general we do not recommend loading the whole file into memory,
  // because video files can get quite large. Use this with caution.
  // highlight-load-into-memory
  NSData *videoData = [NSData dataWithContentsOfURL:result.output.url];

  // Delete the video on disk. If the video was passed without rendering, we won't delete the file.
  // In production this check would not be needed because the app bundle is read-only.
  // Unfortunately, with the Simulator it is not read-only so we need to include this check
  // or the example will crash when opened a second time.
  if (result.status != VESDKVideoEditorStatusPassedWithoutRendering) {
    [[NSFileManager defaultManager] removeItemAtURL:result.output.url error:nil];
  }
  // highlight-load-into-memory

  // You can now use `videoData` for further processing. Dismissing the editor now.
  NSLog(@"Received video data with %lu bytes", (unsigned long)videoData.length);

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
