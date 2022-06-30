#import "VideoStickersConfiguration.h"
@import VideoEditorSDK;

@interface VideoStickersConfigurationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoStickersConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

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
