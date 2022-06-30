#import "VideoAddFontsFromAppBundle.h"
@import VideoEditorSDK;

@interface VideoAddFontsFromAppBundleObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoAddFontsFromAppBundleObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to an image in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a reference to a custom font.
  // highlight-objects
  NSURL *fontURL = [NSBundle.mainBundle URLForResource:@"custom_font_raleway_regular" withExtension:@"ttf"];
  PESDKFont *customFont = [[PESDKFont alloc] initWithUrl:fontURL displayName:@"Raleway" fontName:@"custom_font_raleway_regular" identifier:@"custom_font_raleway_regular"];

  // Create a reference to a system font.
  PESDKFont *systemFont = [[PESDKFont alloc] initWithDisplayName:@"Helvetica" fontName:@"Helvetica" identifier:@"system_font_helvetica"];
  // highlight-objects

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // In this example we are using the default assets for the asset catalog as a base.
    // However, you can also create an empty catalog as well which only contains your
    // custom assets.
    // highlight-catalog
    PESDKAssetCatalog *assetCatalog = PESDKAssetCatalog.defaultItems;

    // Add the custom fonts to the asset catalog.
    assetCatalog.fonts = [assetCatalog.fonts arrayByAddingObjectsFromArray:@[customFont, systemFont]];

    // Use the new asset catalog for the configuration.
    builder.assetCatalog = assetCatalog;
    // highlight-catalog
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
