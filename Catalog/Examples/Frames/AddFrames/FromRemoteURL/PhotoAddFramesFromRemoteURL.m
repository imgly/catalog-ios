#import "PhotoAddFramesFromRemoteURL.h"
@import PhotoEditorSDK;

@interface PhotoAddFramesFromRemoteURLObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoAddFramesFromRemoteURLObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // In this example we are using the default assets for the asset catalog as a base.
    // However, you can also create an empty catalog as well which only contains your
    // custom assets.
    PESDKAssetCatalog *assetCatalog = PESDKAssetCatalog.defaultItems;

    // Create a `PESDKCustomPatchConfiguration` to specify images for a custom frame.
    // highlight-custom-patch
    PESDKCustomPatchConfiguration *frameConfiguration = [[PESDKCustomPatchConfiguration alloc] init];
    // highlight-custom-patch

    // Add `PESDKFrameImageGroup`s to the frame configuration.
    //
    // The frame tool is optimized for remote resources which allows to directly
    // integrate a remote URL instead of downloading the asset before. For an
    // example on how to download the remote resources in advance and use the local
    // downloaded resources, see: Examples/Text/AddFonts/FromRemoteURL.
    //
    // For this example the custom frame has images assigned for each side.
    // However, the frame only needs to have one `PESDKFrameImageGroup` assigned.
    // highlight-image-groups
    frameConfiguration.leftImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:nil midImageURL: [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_left.png"] endImageURL:nil];
    frameConfiguration.rightImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:nil midImageURL: [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_right.png"] endImageURL:nil];

    NSURL *bottomStartImageURL = [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_bottom_left.png"];
    NSURL *bottomEndImageURL = [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_bottom_right.png"];
    NSURL *bottomMidImageURL = [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_bottom.png"];
    frameConfiguration.bottomImageGroup = [[PESDKFrameImageGroup alloc] initWithStartImageURL:bottomStartImageURL midImageURL:bottomMidImageURL endImageURL:bottomEndImageURL];

    NSURL *topStartImageURL = [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_top_left.png"];
    NSURL *topEndImageURL = [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_top_right.png"];
    NSURL *topMidImageURL = [NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_top.png"];
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
    PESDKFrame *customFrame = [[PESDKFrame alloc] initWithFrameBuilder:frameBuilder relativeScale:0.05 thumbnailURL:[NSURL URLWithString:@"https://www.img.ly/static/example-assets/imgly_frame_lowpoly_thumbnail.png"] identifier:@"imgly_frame_lowpoly"];
    // highlight-frame

    // Add the custom frame to the asset catalog.
    // highlight-config
    assetCatalog.frames = [assetCatalog.frames arrayByAddingObjectsFromArray:@[customFrame]];
    // highlight-config

    // Use the new asset catalog for the configuration.
    builder.assetCatalog = assetCatalog;
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
