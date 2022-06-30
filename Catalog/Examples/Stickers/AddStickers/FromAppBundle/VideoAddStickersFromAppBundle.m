#import "VideoAddStickersFromAppBundle.h"
@import VideoEditorSDK;

@interface VideoAddStickersFromAppBundleObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoAddStickersFromAppBundleObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a custom sticker.
  // highlight-load-stickers
  PESDKSticker *customSticker = [[PESDKSticker alloc] initWithImageURL:[NSBundle.mainBundle URLForResource:@"custom_sticker_igor" withExtension:@"png"] thumbnailURL:nil identifier:@"custom_sticker_igor"];

  // Use an existing sticker from the img.ly bundle.
  PESDKSticker *existingSticker = [[PESDKSticker alloc] initWithImageURL:[NSBundle.imgly_resourceBundle URLForResource:@"imgly_sticker_emoticons_laugh" withExtension:@"png"] thumbnailURL:nil identifier:@"existing_sticker"];
  // highlight-load-stickers

  // Assign the stickers to a new custom sticker category.
  // highlight-categories
  PESDKStickerCategory *customStickerCategory = [[PESDKStickerCategory alloc] initWithIdentifier:@"custom_sticker_category" title:@"Custom" imageURL:[NSBundle.mainBundle URLForResource:@"custom_sticker_igor" withExtension:@"png"] stickers:@[customSticker, existingSticker]];
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
