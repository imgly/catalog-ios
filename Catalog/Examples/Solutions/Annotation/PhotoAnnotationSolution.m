#import "PhotoAnnotationSolution.h"
@import PhotoEditorSDK;

@interface PhotoAnnotationSolutionObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoAnnotationSolutionObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // For this example only the sticker, text, and brush tool are enabled.
  // highlight-menu
  NSArray<PESDKToolMenuItem *> *toolItems = @[[PESDKToolMenuItem createStickerToolItem], [PESDKToolMenuItem createTextToolItem], [PESDKToolMenuItem createBrushToolItem]];
  
  NSMutableArray<PESDKPhotoEditMenuItem *> *menuItems = [NSMutableArray array];
  [toolItems enumerateObjectsUsingBlock:^(PESDKToolMenuItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
    PESDKPhotoEditMenuItem *menuItem = [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:item];
    [menuItems addObject:menuItem];
  }];
  // highlight-menu

  // For this example only stickers suitable for annotations are enabled.
  // highlight-stickers
  NSArray<NSString *> *stickerIdentifiers = @[
    @"imgly_sticker_shapes_arrow_02",
    @"imgly_sticker_shapes_arrow_03",
    @"imgly_sticker_shapes_badge_11",
    @"imgly_sticker_shapes_badge_12",
    @"imgly_sticker_shapes_badge_36"
  ];
  NSMutableArray<PESDKSticker *> *stickers = [NSMutableArray array];

  [stickerIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull identifier, NSUInteger idx, BOOL * _Nonnull stop) {
    NSURL *stickerURL = [NSBundle.imgly_resourceBundle URLForResource:identifier withExtension:@"png"];
    PESDKSticker *sticker = [[PESDKSticker alloc] initWithImageURL:stickerURL thumbnailURL:nil identifier:identifier];
    [stickers addObject:sticker];
  }];

  // Create a custom sticker category for the annotation stickers.
  NSURL *stickerCategoryURL = [NSBundle.imgly_resourceBundle URLForResource:@"imgly_sticker_shapes_arrow_02" withExtension:@"png"];
  PESDKStickerCategory *stickerCategory = [[PESDKStickerCategory alloc] initWithTitle:@"Annotation" imageURL:stickerCategoryURL stickers:stickers];
  // highlight-stickers

  // Create a `PESDKConfiguration` object.
  // highlight-config
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Add the annotation sticker category to the asset catalog.
    builder.assetCatalog.stickers = @[stickerCategory];

    // Configure the `PESDKPhotoEditViewController`.
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      // Assign the custom selection of tools.
      options.menuItems = menuItems;
    }];
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
