#import "VideoAddOverlaysFromRemoteURL.h"
@import VideoEditorSDK;

@interface VideoAddOverlaysFromRemoteURLObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoAddOverlaysFromRemoteURLObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a custom `PESDKOverlay`.
  // The overlay tool is optimized for remote resources which allows to directly
  // integrate a remote URL instead of downloading the asset before. For an
  // example on how to download the remote resources in advance and use the local
  // downloaded resources, see: Examples/Text/AddFonts/FromRemoteURL.
  // highlight-custom-overlays
  NSURL *overlayURL = [NSURL URLWithString:@"https://img.ly/static/example-assets/imgly_overlay_grain.jpg"];
  PESDKOverlay *customOverlay = [[PESDKOverlay alloc] initWithIdentifier:@"imgly_overlay_grain" displayName:@"Grain" url:overlayURL thumbnailURL:nil initialBlendMode:PESDKBlendModeHardLight];
  // highlight-custom-overlays

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // In this example we are using the default assets for the asset catalog as a base.
    // However, you can also create an empty catalog as well which only contains your
    // custom assets.
    // highlight-catalog
    PESDKAssetCatalog *assetCatalog = [PESDKAssetCatalog defaultItems];

    // Add the custom overlay to the asset catalog.
    assetCatalog.overlays = [assetCatalog.overlays arrayByAddingObject:customOverlay];

    // Use the new asset catalog for the configuration.
    builder.assetCatalog = assetCatalog;
    // highlight-catalog
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
