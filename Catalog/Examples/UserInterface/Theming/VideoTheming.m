#import "VideoTheming.h"
@import VideoEditorSDK;

@interface VideoThemingObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoThemingObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

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

  // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
  videoEditViewController.delegate = self;
  videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
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
