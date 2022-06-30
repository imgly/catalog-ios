#import "PhotoCustomizeMenuItems.h"
@import PhotoEditorSDK;

@interface PhotoCustomizeMenuItemsObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoCustomizeMenuItemsObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure settings related to the `PESDKPhotoEditViewController`.
    // highlight-configure
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      // Configure the available tool menu items to be displayed in the main menu.
      // Menu items for tools not included in your license subscription will be hidden automatically.
      options.menuItems = [@[
        // Create the default `PESDKMenuItem`s and convert them to `PESDKPhotoEditMenuItem`s.
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
        [[PESDKPhotoEditMenuItem alloc] initWithActionMenuItem:[PESDKActionMenuItem createMagicItem]],
      ] sortedArrayUsingComparator:^NSComparisonResult(PESDKPhotoEditMenuItem * _Nonnull a, PESDKPhotoEditMenuItem * _Nonnull b) {
        // Sort the menu items by their title for demonstration purposes.
        NSString *titleA = a.toolMenuItem ? a.toolMenuItem.title : a.actionMenuItem.title;
        NSString *titleB = b.toolMenuItem ? b.toolMenuItem.title : b.actionMenuItem.title;
        return [titleA compare:titleB];
      }];
    }];
    // highlight-configure
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
