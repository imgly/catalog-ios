#import "VideoAnnotationSolution.h"
@import VideoEditorSDK;

@interface VideoAnnotationSolutionObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoAnnotationSolutionObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to an image in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

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

    // Configure the `PESDKVideoEditViewController`.
    [builder configureVideoEditViewController:^(PESDKVideoEditViewControllerOptionsBuilder * _Nonnull options) {
      // Assign the custom selection of tools.
      options.menuItems = menuItems;
    }];
  }];
  // highlight-config

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
