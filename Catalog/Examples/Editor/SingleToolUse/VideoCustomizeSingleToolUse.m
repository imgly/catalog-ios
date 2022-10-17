#import "VideoCustomizeSingleToolUse.h"
@import VideoEditorSDK;

@interface VideoCustomizeSingleToolUseObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoCustomizeSingleToolUseObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure settings related to the `PESDKVideoEditViewController`.
    [builder configureVideoEditViewController:^(PESDKVideoEditViewControllerOptionsBuilder * _Nonnull options) {
      // highlight-configure
      // Configure the tool menu item to be displayed as single tool.
      // Make sure your license includes the tool you want to use.
      options.menuItems = @[
        // Create one of the supported tools.
        // We will create composition or trim tool.
        [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createCompositionOrTrimToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createTrimToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createTransformToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFilterToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createAdjustToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createFocusToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createOverlayToolItem]]
        // [[PESDKPhotoEditMenuItem alloc] initWithToolMenuItem:[PESDKToolMenuItem createBrushToolItem]]
      ];
      // highlight-configure
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
