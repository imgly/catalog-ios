#import "VideoCustomizeMenuItems.h"
@import VideoEditorSDK;

@interface VideoCustomizeMenuItemsObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoCustomizeMenuItemsObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure settings related to the `PESDKVideoEditViewController`.
    // highlight-configure
    [builder configureVideoEditViewController:^(PESDKVideoEditViewControllerOptionsBuilder * _Nonnull options) {
      // Configure the available tool menu items to be displayed in the main menu.
      // Menu items for tools not included in your license subscription will be hidden automatically.
      options.menuItems = [@[
        // Create the default `PESDKMenuItem`s and convert them to `PESDKPhotoEditMenuItem`s.
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createCompositionOrTrimToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createAudioToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createTransformToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFilterToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createAdjustToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFocusToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createStickerToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createTextToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createTextDesignToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createOverlayToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFrameToolItem]],
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createBrushToolItem]],
      ] sortedArrayUsingComparator:^NSComparisonResult(PESDKPhotoEditMenuItem * _Nonnull a, PESDKPhotoEditMenuItem * _Nonnull b) {
        // Sort the menu items by their title for demonstration purposes.
        NSString *titleA = a.toolMenuItem ? a.toolMenuItem.title : a.actionMenuItem.title;
        NSString *titleB = b.toolMenuItem ? b.toolMenuItem.title : b.actionMenuItem.title;
        return [titleA compare:titleB];
      }];
    }];
    // highlight-configure
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
