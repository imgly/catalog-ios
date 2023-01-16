#import "PhotoLinkSmartSticker.h"
#import "Catalog-Swift.h"
@import PhotoEditorSDK;

@interface PhotoLinkSmartStickerObjC() <PESDKPhotoEditViewControllerDelegate>

- (void)invokeExample;

@end

@implementation PhotoLinkSmartStickerObjC

- (void)invokeExample {
  // Create a `Photo` from a URL to an image in the app bundle.
  NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"LA" withExtension:@"jpg"];
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:photoURL];

  // Create an asset catalog with default items that we will use to add
  // our smart sticker.
  PESDKAssetCatalog *assetCatalog = [PESDKAssetCatalog defaultItems];

  // For this example we will create a smart sticker with multiple
  // variations so we will define few colors for background box, text
  // and icon color.
  // highlight-variations
  UIColor *boxColor1 = [[UIColor alloc] initWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:0.55];
  UIColor *boxColor2 = [[UIColor alloc] initWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
  UIColor *boxColor3 = [[UIColor alloc] initWithRed:51/255.0 green:51/255.0 blue:55/255.0 alpha:0.55];
  UIColor *boxColor4 = [[UIColor alloc] initWithRed:51/255.0 green:51/255.0 blue:55/255.0 alpha:1.0];
  NSArray<UIColor *> *boxColors = @[boxColor1, boxColor2, boxColor3, boxColor4];

  UIColor *textColor1 = [[UIColor alloc] initWithRed:51/255.0 green:51/255.0 blue:55/255.0 alpha:1.0];
  UIColor *textColor2 = [[UIColor alloc] initWithRed:51/255.0 green:51/255.0 blue:55/255.0 alpha:1.0];
  UIColor *textColor3 = [[UIColor alloc] initWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
  UIColor *textColor4 = [[UIColor alloc] initWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
  NSArray<UIColor *> *textColors = @[textColor1, textColor2, textColor3, textColor4];

  UIColor *iconColor1 = [[UIColor alloc] initWithRed:51/255.0 green:51/255.0 blue:55/255.0 alpha:1.0];
  UIColor *iconColor2 = [[UIColor alloc] initWithRed:38/255.0 green:119/255.0 blue:253/255.0 alpha:1.0];
  UIColor *iconColor3 = [[UIColor alloc] initWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
  UIColor *iconColor4 = [[UIColor alloc] initWithRed:255/255.0 green:92/255.0 blue:0/255.0 alpha:1.0];

  NSArray<UIColor *> *iconColors = @[iconColor1, iconColor2, iconColor3, iconColor4];

  // Create 4 instances of LinkSmartSticker that is defined in Swift.
  // For implementation of the sticker, look at Swift counterpart of this example.
  NSMutableArray<PhotoLinkSmartSticker *> *multiLinkStickers = [NSMutableArray arrayWithCapacity:4];
  for (int i = 0; i < 4; i++) {
    PLinkSmartSticker *linkSmartSticker = [[PLinkSmartSticker alloc] initWithIdentifier:[NSString stringWithFormat:@"imgly_link_smart_sticker_%d", i+1] textColor:textColors[i] boxColor:boxColors[i] iconColor:iconColors[i]];
    [multiLinkStickers addObject:linkSmartSticker];
  }


  // When we have stickers generated we will add them to a MultiImageSticker
  // that will allow us to change between variations with tapping on the
  // sticker on the canvas.
  PESDKMultiImageSticker *multiLinkSticker = [[PESDKMultiImageSticker alloc] initWithIdentifier:@"imgly_link_smart_sticker" imageURL:nil stickers:multiLinkStickers];
  // highlight-variations

  // For this example we will create a sticker category that will only hold
  // our Multi LinkSmartSticker.
  // highlight-stickers
  NSURL *imageURL = [[NSBundle imgly_resourceBundle] URLForResource:@"imgly_sticker_shapes_arrow_02" withExtension:@"png"];
  PESDKStickerCategory *stickerCategory = [[PESDKStickerCategory alloc] initWithIdentifier:@"smart_stickers" title:@"Smart Stickers" imageURL:imageURL stickers:@[multiLinkSticker]];
  assetCatalog.stickers = @[stickerCategory];
  // highlight-stickers


  // Create a `Configuration` object.
  // highlight-config
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    builder.assetCatalog = assetCatalog;
  }];
  // highlight-config

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

  // highlight-query-metadata
  // Here we can query what URLs were entered by the user.
  NSArray<NSString *> *stickerLinks = [result.task.model.spriteModels valueForKeyPath:@"metadata.url"];
  NSLog(@"%@", stickerLinks);
  // highlight-query-metadata

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
