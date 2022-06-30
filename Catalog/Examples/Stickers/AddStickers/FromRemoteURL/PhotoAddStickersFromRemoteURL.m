#import "PhotoAddStickersFromRemoteURL.h"
@import PhotoEditorSDK;

@interface PhotoAddStickersFromRemoteURLObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoAddStickersFromRemoteURLObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a custom sticker.
  // The sticker tool is optimized for remote resources which allows to directly
  // integrate a remote URL instead of downloading the asset before. For an
  // example on how to download the remote resources in advance and use the local
  // downloaded resources, see: Examples/Text/AddFonts/FromRemoteURL.
  // highlight-load-stickers
  PESDKSticker *customSticker = [[PESDKSticker alloc] initWithImageURL:[NSURL URLWithString:@"https://img.ly/static/example-assets/custom_sticker_igor.png"] thumbnailURL:nil identifier:@"custom_sticker_igor"];

  // Use an existing sticker from the img.ly bundle.
  PESDKSticker *existingSticker = [[PESDKSticker alloc] initWithImageURL:[NSBundle.imgly_resourceBundle URLForResource:@"imgly_sticker_emoticons_laugh" withExtension:@"png"] thumbnailURL:nil identifier:@"existing_sticker"];
  // highlight-load-stickers

  // Assign the stickers to a new custom sticker category.
  // highlight-categories
  PESDKStickerCategory *customStickerCategory = [[PESDKStickerCategory alloc] initWithIdentifier:@"custom_sticker_category" title:@"Custom" imageURL:[NSURL URLWithString:@"https://img.ly/static/example-assets/custom_sticker_igor.png"] stickers:@[customSticker, existingSticker]];
  // highlight-categories

  // Create a `PESDKConfiguration` object.
  // highlight-configure
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // In this example we are using the default assets for the asset catalog as a base.
    // However, you can also create an empty catalog as well which only contains your
    // custom assets.
    PESDKAssetCatalog *assetCatalog = PESDKAssetCatalog.defaultItems;

    // Add the category to the asset catalog.
    assetCatalog.stickers = [assetCatalog.stickers arrayByAddingObject:customStickerCategory];

    // Use the new asset catalog for the configuration.
    builder.assetCatalog = assetCatalog;
  }];
  // highlight-configure

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
