#import "ConfigurationExample.h"
@import PhotoEditorSDK;

@implementation ConfigurationExampleObjC

- (void)invokeExample {
  // highlight-build-class
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // highlight-build-class

    // highlight-global-config
    builder.theme.backgroundColor = UIColor.whiteColor;
    builder.theme.menuBackgroundColor = UIColor.lightGrayColor;
    // highlight-global-config

    // highlight-controller-config
    [builder configureCameraViewController:^(PESDKCameraViewControllerOptionsBuilder * _Nonnull options) {
      options.showCancelButton = YES;
      options.cropToSquare = YES;
      // highlight-controller-config

      // highlight-closure-config
      options.cameraRollButtonConfigurationClosure = ^(PESDKButton * _Nonnull button) {
        button.layer.borderWidth = 2.0;
        button.layer.borderColor = UIColor.redColor.CGColor;
      };
      // highlight-closure-config
    }];
  }];

  PESDKCameraViewController *cameraViewController = [[PESDKCameraViewController alloc] initWithConfiguration:configuration];
  cameraViewController.cancelBlock = ^{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  };

  cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:cameraViewController animated:YES completion:nil];
}

@end
