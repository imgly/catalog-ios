#import "PhotoTheming.h"
@import PhotoEditorSDK;

@interface PhotoThemingObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoThemingObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // The recommended way to change the appearance of the UI elements is by configuring the `PESDKTheme`.
    // The default is a dark color theme but there is also a predefined light color theme. Here we
    // use a theme that switches dynamically between the light and the dark theme based on the active
    // `UITraitCollection.userInterfaceStyle`.
    // highlight-light-dark
    builder.theme = PESDKTheme.dynamic;
    // highlight-light-dark

    // The base colors of the UI elements can be customized at a central place by modifying the properties of the theme.
    // Use a static color.
    // highlight-colors
    builder.theme.backgroundColor = UIColor.darkGrayColor;
    // Use system colors that automatically adapt to the current trait environment.
    builder.theme.menuBackgroundColor = UIColor.secondarySystemBackgroundColor;
    builder.theme.toolbarBackgroundColor = UIColor.tertiarySystemBackgroundColor;
    builder.theme.primaryColor = UIColor.labelColor;
    // Define and use a custom color that automatically adapts to the current trait environment.
    builder.theme.tintColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
      return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? UIColor.greenColor : UIColor.redColor;
    }];
    // highlight-colors

    // This closure is called after the theme was applied via `UIAppearance` proxies during the initialization of a `CameraViewController` or a `MediaEditViewController` subclass.
    // It is intended to run custom calls to `UIAppearance` proxies to customize specific UI components. The API documentation highlights when a specific property can be configured
    // with the `UIAppearance` proxy API.
    // highlight-ui-elements
    builder.appearanceProxyConfigurationClosure = ^(PESDKTheme * _Nonnull theme) {
    // highlight-ui-elements
      // The immutable active theme is passed to this closure and can be used to configure appearance properties.
      // Change the appearance of all overlay buttons.
      // highlight-overlay-buttons
      [PESDKOverlayButton appearanceWhenContainedInInstancesOfClasses:@[PESDKMediaEditViewController.class]].tintColor = theme.tintColor;
      PESDKOverlayButton.appearance.backgroundColor = [UIColor.systemBackgroundColor colorWithAlphaComponent:0.3];
      // highlight-overlay-buttons

      // Change the appearance of all menu cells.
      // highlight-menu-cells
      PESDKMenuCollectionViewCell.appearance.selectionBorderWidth = 3;
      PESDKMenuCollectionViewCell.appearance.cornerRadius = 5;
      // highlight-menu-cells
    };
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
