#import "PhotoEditorConfiguration.h"
@import PhotoEditorSDK;

@interface PhotoEditorConfigurationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoEditorConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];
  
  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      // By default the editor allows to zoom the image in the preview.
      // For this example, this behavior is disabled.
      options.allowsPreviewImageZoom = false;

      // By default the editor uses a compression quality of 90% (0.9)
      // for lossy export formats.
      // For this example the compression quality is set to 25% (0.25)
      // e.g. for when the exported image is only used as a thumbnail.
      options.compressionQuality = 0.25;

      // By default the editor has insets of 12 pt for each side - except for top
      // since this value is ignored.
      // For this example the insets are set to increase the spacing.
      options.overlayButtonInsets = UIEdgeInsetsMake(0, 15, 15, 15);

      // By default the editor exports the image in JPG format.
      // For this example the editor should export the image as HEIF
      // to improve compression efficiency.
      options.outputImageFileFormat = PESDKImageFileFormatHeif;
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
