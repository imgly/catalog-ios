#import "PhotoCustomizeSingleToolUse.h"
@import PhotoEditorSDK;

@interface PhotoCustomizeSingleToolUseObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoCustomizeSingleToolUseObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure settings related to the `PESDKPhotoEditViewController`.
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      // highlight-configure
      // Configure the tool menu item to be displayed as single tool.
      // Make sure your license includes the tool you want to use.
      options.menuItems = @[
        // Create one of the supported tools.
        // We will create filter tool.
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFilterToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createTransformToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createAdjustToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFocusToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createOverlayToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createBrushToolItem]]
      ];
      // highlight-configure
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
