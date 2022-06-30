#import "ShowVideoCameraUIKit.h"
@import VideoEditorSDK;

@interface ShowVideoCameraUIKitObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation ShowVideoCameraUIKitObjC

- (void)invokeExample {
  // Create a `PESDKConfiguration` object.
  // highlight-configuration
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
      // By default the camera view controller does not show a cancel button,
      // so that it can be embedded into any other view controller. But since it is
      // presented modally here, a cancel button should be visible.
      options.showCancelButton = YES;

      // Enable video only.
      options.allowedRecordingModes = @[@(RecordingModeVideo)];
    }];
  }];

  // Create the camera view controller passing above configuration.
  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  // highlight-configuration

  // The `cancelBlock` will be called when the user taps the cancel button.
  // highlight-cancel-block
  [cameraViewController setCancelBlock:^{
    // Dismiss the camera view controller.
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }];
  // highlight-cancel-block

  // The `completionBlock` will be called when the user selects a video from the camera roll
  // or finishes recording a video.
  // highlight-completion-block
  [cameraViewController setCompletionBlock:^(PESDKCameraResult * _Nonnull result) {
    if (result.url != nil) {
      // Dismiss the camera view controller and open the video editor after dismissal.
      [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        // Create a `PESDKVideo` from the `NSURL` object.
        PESDKVideo *video = [[PESDKVideo alloc] initWithURL:result.url];

        // Create a default `PESDKConfiguration`.
        PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

        // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
        // Passing the `result.model` to the editor to preserve selected filters.
        PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration photoEditModel:result.model];
        videoEditViewController.delegate = self;
        videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
      }];
    }
  }];
  // highlight-completion-block

  // Present the camera view controller.
  // To take photos, the camera will require the `NSCameraUsageDescription` key to be present in your Info.plist file.
  // To access photos in the camera roll, the camera will require the `NSPhotoLibraryUsageDescription` key to be present in your Info.plist file.
  // To record videos, the camera will require the `NSMicrophoneUsageDescription` key to be present in your Info.plist file.
  // highlight-present
  cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:cameraViewController animated:YES completion:nil];
  // highlight-present
}

#pragma mark - PESDKVideoEditViewControllerDelegate

- (BOOL)videoEditViewControllerShouldStart:(PESDKVideoEditViewController * _Nonnull)videoEditViewController task:(PESDKVideoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

 - (void)videoEditViewControllerDidFinish:(PESDKVideoEditViewController * _Nonnull)videoEditViewController result:(PESDKVideoEditorResult * _Nonnull)result {
  // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor.
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
