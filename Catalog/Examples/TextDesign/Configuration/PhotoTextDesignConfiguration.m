#import "PhotoTextDesignConfiguration.h"
@import PhotoEditorSDK;

@interface PhotoTextDesignConfigurationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoTextDesignConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKTextDesignToolController` that lets the user
    // add text designs to the image.
    [builder configureTextDesignToolController:^(PESDKTextDesignToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor allows to add emojis as text input.
      // Since emojis are not cross-platform compatible, using the serialization
      // feature to share edits across different platforms will result in emojis
      // being rendered with the system's local set of emojis and therefore will
      // appear differently.
      // For this example emoji input is disabled to ensure a consistent cross-platform experience.
      // highlight-emojis
      options.emojisEnabled = false;
      // highlight-emojis

      // By default the editor provides a `PESDKColorPalette` with a lot of colors.
      // For this example this will be replaced with a `ColorPalette`
      // with only a few colors enabled.
      // highlight-color
      options.colorPalette = [[PESDKColorPalette alloc] initWithColors:@[
        [[PESDKColor alloc] initWithColor:UIColor.whiteColor colorName:@"White"],
        [[PESDKColor alloc] initWithColor:UIColor.blackColor colorName:@"Black"]
      ]];
      // highlight-color
    }];

    // Configure the `PESDKTextDesignOptionsToolController` that lets the user
    // change text designs that have been placed on top of the image.
    // highlight-actions
    [builder configureTextDesignOptionsToolController:^(PESDKTextDesignOptionsToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor has all available overlay actions for this tool
      // enabled. For this example `TextDesignOverlayActionUndo` and `TextDesignOverlayActionRedo`
      // are removed.
      options.allowedTextDesignOverlayActions = @[@(TextDesignOverlayActionAdd), @(TextDesignOverlayActionBringToFront), @(TextDesignOverlayActionDelete), @(TextDesignOverlayActionInvert)];
    }];
    // highlight-actions
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
