#import "ShowPhotoCameraUIKit.h"
@import PhotoEditorSDK;

@interface ShowPhotoCameraUIKitObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation ShowPhotoCameraUIKitObjC

- (void)invokeExample {
  // Create a `PESDKConfiguration` object.
  // highlight-configuration
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
      // By default the camera view controller does not show a cancel button,
      // so that it can be embedded into any other view controller. But since it is
      // presented modally here, a cancel button should be visible.
      options.showCancelButton = YES;

      // Enable photo only.
      options.allowedRecordingModes = @[@(RecordingModePhoto)];
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

  // The `completionBlock` will be called once a photo has been taken. The `Data` argument
  // will contain the photo in JPEG format with all EXIF information.
  // highlight-completion-block
  [cameraViewController setCompletionBlock:^(PESDKCameraResult * _Nonnull result) {
    if (result.data != nil) {
      [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        // Create a `PESDKPhoto` from the `NSData` object.
        PESDKPhoto *photo = [[PESDKPhoto alloc] initWithData:result.data];

        // Create a default `PESDKConfiguration`.
        PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

        // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
        // Passing the `result.model` to the editor to preserve selected filters.
        PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration photoEditModel: result.model];
        photoEditViewController.delegate = self;
        photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];
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
