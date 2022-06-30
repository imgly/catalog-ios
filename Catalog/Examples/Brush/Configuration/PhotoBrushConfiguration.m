#import "PhotoBrushConfiguration.h"
@import PhotoEditorSDK;

@interface PhotoBrushConfigurationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoBrushConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKBrushToolController` which lets the user
    // draw on the image.
    [builder configureBrushToolController:^(PESDKBrushToolControllerOptionsBuilder * _Nonnull options) {
      // By default all available brush tools are enabled.
      // For this example only a couple are enabled.
      // highlight-tools
      options.allowedBrushTools = @[@(BrushToolColor), @(BrushToolSize)];
      // highlight-tools

      // By default the default color for the brush stroke is
      // `UIColor.whiteColor`. For this example the default color
      // is set to `UIColor.blackColor`.
      // highlight-color
      options.defaultBrushColor = UIColor.blackColor;
      // highlight-color

      // By default the default brush size is set to 5% of the
      // smaller side of the image.
      // For this example the default size should be absolute.
      // highlight-size
      options.defaultBrushSize = [[PESDKFloatValue alloc] initWithAbsoluteValue:5];
      // highlight-size
    }];

    // Configure the `PESDKBrushColorToolController` which lets the user
    // change the color of the brush stroke.
    [builder configureBrushColorToolController:^(PESDKBrushColorToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor provides a variety of different
      // colors to customize the color of the brush stroke.
      // For this example only a small selection of colors is enabled.
      // highlight-colors
      options.availableColors = @[
        [[PESDKColor alloc] initWithColor:UIColor.whiteColor colorName:@"White"],
        [[PESDKColor alloc] initWithColor:UIColor.blackColor colorName:@"Black"],
        [[PESDKColor alloc] initWithColor:UIColor.redColor colorName:@"Red"]
      ];
      // highlight-colors
    }];
  }];

  // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration];
  photoEditViewController.delegate = self;
  photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];
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
