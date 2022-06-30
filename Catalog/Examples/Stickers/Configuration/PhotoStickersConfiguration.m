#import "PhotoStickersConfiguration.h"
@import PhotoEditorSDK;

@interface PhotoStickersConfigurationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoStickersConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // By default the editor provides a variety of different stickers.
    // For this example the editor should only use the "Shapes" sticker
    // category.
    // highlight-categories
    builder.assetCatalog.stickers = [PESDKAssetCatalog.defaultItems.stickers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PESDKStickerCategory * _Nonnull stickerCategory, NSDictionary * _Nullable bindings) {
      return [stickerCategory.identifier isEqualToString:@"imgly_sticker_category_shapes"];
    }]];
    // highlight-categories

    // Configure the `PESDKStickerToolController` which lets the user
    // select the sticker.
    [builder configureStickerToolController:^(PESDKStickerToolControllerOptionsBuilder * _Nonnull options) {
      // By default the user is not allowed to add custom stickers.
      // In this example the user can add stickers from the device.
      // highlight-personalized
      options.personalStickersEnabled = true;
      // highlight-personalized

      // By default the preview size of the stickers inside the sticker
      // tool is set to `CGSizeMake(44, 44)`.
      // For this example the preview size is set to a bigger size.
      // highlight-preview-size
      options.stickerPreviewSize = CGSizeMake(60, 60);
      // highlight-preview-size
    }];

    // Configure the `PESDKStickerOptionsToolController` which lets the user
    // customize a selected sticker when added to the canvas.
    [builder configureStickerOptionsToolController:^(PESDKStickerOptionsToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor enables all available sticker actions.
      // For this example only a small selection of sticker actions
      // should be allowed.
      // highlight-actions
      options.allowedStickerActions = @[@(StickerActionReplace), @(StickerActionColor)];
      // highlight-actions
    }];

    // Configure the `PESDKStickerColorToolController` which lets the user
    // change the color of the sticker.
    [builder configureStickerColorToolController:^(PESDKColorToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor provides a variety of different
      // colors to customize the stickers.
      // For this example only a small selection of colors is enabled
      // per default.
      // highlight-color-tool
      options.availableColors = @[
        [[PESDKColor alloc] initWithColor:UIColor.whiteColor colorName:@"White"],
        [[PESDKColor alloc] initWithColor:UIColor.blackColor colorName:@"Black"],
        [[PESDKColor alloc] initWithColor:UIColor.darkGrayColor colorName:@"Dark Gray"],
        [[PESDKColor alloc] initWithColor:UIColor.grayColor colorName:@"Gray"],
      ];
      // highlight-color-tool
    }];
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
