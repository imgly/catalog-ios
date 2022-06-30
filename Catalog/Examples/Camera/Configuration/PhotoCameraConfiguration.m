#import "PhotoCameraConfiguration.h"
@import AVFoundation;
@import PhotoEditorSDK;

@implementation PhotoCameraConfigurationObjC

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
      // take a photo. Since we are only using PE.SDK here, recording a video should not
      // be allowed.
      // highlight-modes
      options.allowedRecordingModes = @[@(RecordingModePhoto)];
      // highlight-modes

      // By default the camera view controller allows all camera positions. The first
      // position will be selected by default.
      // For this example, the camera should open with the front camera first, e.g.
      // for taking a profile picture.
      // highlight-position
      options.allowedCameraPositions = @[@(AVCaptureDevicePositionFront), @(AVCaptureDevicePositionBack)];
      // highlight-position

      // By default the camera does not crop the image to a square.
      // In this example, we force the camera to crop the input image to a
      // square, e.g. for having symmetric profile picture image dimensions.
      // highlight-crop
      options.cropToSquare = true;
      // highlight-crop

      // By default, the camera allows all recording modes. If the current orientation
      // of the device does not match any of the specified orientations the first one
      // of these is used.
      // For this example, we only allow the `RecordingOrientationPortrait` orientation,
      // e.g. for all profile images to have the same orientation.
      // highlight-orientation
      options.allowedRecordingOrientations = @[@(RecordingOrientationPortrait)];
      // highlight-orientation
    }];
  }];

  // Create the camera view controller passing above configuration.
  // The camera only runs on physical devices. On the simulator, only the image picker is enabled.
  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;

  // The `completionBlock` will be called once a photo has been taken or when the user selects a photo from the camera roll.
  [cameraViewController setCompletionBlock:^(PESDKCameraResult * _Nonnull result) {
    // You can now use `result.data` for further processing.
    // The `result.data` will contain the photo in JPEG format with all EXIF information.
    // The `result.url` is not needed since we are only using PE.SDK.
    // Dismissing the camera now.
    if (result.data != nil) {
      NSLog(@"Received image data with %lu bytes", (unsigned long)result.data.length);
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
