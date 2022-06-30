#import "VideoAddFramesFromAppBundle.h"
@import VideoEditorSDK;

@interface VideoAddFramesFromAppBundleObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoAddFramesFromAppBundleObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKCustomPatchConfiguration` to specify images for a custom frame.
  // highlight-custom-patch
  PESDKCustomPatchConfiguration *frameConfiguration = [[PESDKCustomPatchConfiguration alloc] init];
  // highlight-custom-patch

  // Add `PESDKFrameImageGroup`s to the frame configuration.
  // For this example the custom frame has images assigned for each side.
  // However, the frame only needs to have one `PESDKFrameImageGroup` assigned.
  // highlight-image-groups
  frameConfiguration.leftImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:nil midImageURL:[NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_left" withExtension:@"png"] endImageURL:nil];
  frameConfiguration.rightImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:nil midImageURL:[NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_right" withExtension:@"png"] endImageURL:nil];

  NSURL *bottomStartImageURL = [NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_bottom_left" withExtension:@"png"];
  NSURL *bottomEndImageURL = [NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_bottom_right" withExtension:@"png"];
  NSURL *bottomMidImageURL = [NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_bottom" withExtension:@"png"];
  frameConfiguration.bottomImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:bottomStartImageURL midImageURL:bottomMidImageURL endImageURL:bottomEndImageURL];

  NSURL *topStartImageURL = [NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_top_left" withExtension:@"png"];
  NSURL *topEndImageURL = [NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_top_right" withExtension:@"png"];
  NSURL *topMidImageURL = [NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_top" withExtension:@"png"];
  frameConfiguration.topImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:topStartImageURL midImageURL:topMidImageURL endImageURL:topEndImageURL];
  // highlight-image-groups

  // By default the `midImageMode` is set to `FrameTileModeRepeat` which repeats
  // the middle image to fill out the entire space.
  // For this example it is set to `FrameTileModeStretch` for all image groups
  // to keep the correct pattern. In this mode, the middle image is
  // stretched to fill out the entire space.
  // highlight-image-modes
  frameConfiguration.topImageGroup.midImageMode = FrameTileModeStretch;
  frameConfiguration.leftImageGroup.midImageMode = FrameTileModeStretch;
  frameConfiguration.rightImageGroup.midImageMode = FrameTileModeStretch;
  frameConfiguration.bottomImageGroup.midImageMode = FrameTileModeStretch;
  // highlight-image-modes

  // Create a `PESDKCustomPatchFrameBuilder` responsible to render a custom frame.
  // highlight-frame
  PESDKCustomPatchFrameBuilder *frameBuilder = [[PESDKCustomPatchFrameBuilder alloc] initWithConfiguration:frameConfiguration];

  // Create a custom `PESDKFrame`.
  PESDKFrame *customFrame = [[PESDKFrame alloc] initWithFrameBuilder:frameBuilder relativeScale:0.05 thumbnailURL:[NSBundle.mainBundle URLForResource:@"imgly_frame_lowpoly_thumbnail" withExtension:@"png"] identifier:@"imgly_frame_lowpoly"];
  // highlight-frame

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // In this example we are using the default assets for the asset catalog as a base.
    // However, you can also create an empty catalog as well which only contains your
    // custom assets.
    PESDKAssetCatalog *assetCatalog = PESDKAssetCatalog.defaultItems;

    // Add the custom frame to the asset catalog.
    // highlight-config
    assetCatalog.frames = [assetCatalog.frames arrayByAddingObjectsFromArray:@[customFrame]];
    // highlight-config

    // Use the new asset catalog for the configuration.
    builder.assetCatalog = assetCatalog;
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
