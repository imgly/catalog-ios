#import "PhotoAddFontsFromAppBundle.h"
@import PhotoEditorSDK;

@interface PhotoAddFontsFromAppBundleObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoAddFontsFromAppBundleObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

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
