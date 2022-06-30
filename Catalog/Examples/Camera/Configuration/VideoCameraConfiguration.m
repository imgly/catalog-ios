#import "VideoCameraConfiguration.h"
@import AVFoundation;
@import VideoEditorSDK;

@implementation VideoCameraConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKConfiguration` object.
  //
  // For replacing the live filters of the camera please see the
  // examples at Filters/AddFilters.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
      // By default the camera view controller does not show a cancel button,
      // so that it can be embedded into any other view controller. But since it is
      // presented modally here, a cancel button should be visible.
      // highlight-show-cancel
      options.showCancelButton = true;
      // highlight-show-cancel

      // By default the camera view controller allows to both record a video as well as
      // take a photo. Since we are only using VE.SDK here, taking a photo should not
      // be allowed.
      // highlight-modes
      options.allowedRecordingModes = @[@(RecordingModeVideo)];
      // highlight-modes

      // By default the camera view controller allows all camera positions. The first
      // position will be selected by default.
      // For this example, the camera should open with the front camera first, e.g.
      // for recording a personal vlog.
      // highlight-position
      options.allowedCameraPositions = @[@(AVCaptureDevicePositionFront), @(AVCaptureDevicePositionBack)];
      // highlight-position

      // By default, the camera allows all recording modes. If the current orientation
      // of the device does not match any of the specified orientations the first one
      // of these is used.
      // For this example, we only allow the `.portrait` orientation, e.g. for all
      // social media posts to have the same orientation.
      // highlight-orientation
      options.allowedRecordingOrientations = @[@(RecordingOrientationPortrait)];
      // highlight-orientation
    }];
  }];

  // Create the camera view controller passing above configuration.
  // The camera only runs on physical devices. On the simulator, only the image picker is enabled.
  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;

  // The `completionBlock` will be called when the user selects a video from the camera roll
  // or finishes recording a video.
  [cameraViewController setCompletionBlock:^(PESDKCameraResult * _Nonnull result) {
    // You can now use `result.url` for further processing.
    // The `result.data` is not needed since we are only using VE.SDK.
    // Dismissing the camera now.
    if (result.url != nil) {
      NSLog(@"Received video at %@.", result.url.absoluteString);
      [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
  }];

  // The `cancelBlock` will be called when the user taps the cancel button.
  [cameraViewController setCancelBlock:^{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }];

  [self.presentingViewController presentViewController:cameraViewController animated:YES completion:nil];
}

@end
