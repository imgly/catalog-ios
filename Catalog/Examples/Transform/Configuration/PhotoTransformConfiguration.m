#import "PhotoTransformConfiguration.h"
@import PhotoEditorSDK;

@interface PhotoTransformConfigurationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoTransformConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKTransformToolController` that lets the user
    // crop and rotate the image.
    [builder configureTransformToolController:^(PESDKTransformToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor has a lot of crop aspects enabled.
      // For this example only a couple are enabled, e.g. if you
      // only allow certain image aspects in your application.
      // highlight-crop-ratios
      options.allowedCropRatios = @[
        [[PESDKCropAspect alloc] initWithWidth:1 height:1],
        [[PESDKCropAspect alloc] initWithWidth:16 height:9 localizedName:@"Landscape"],
      ];
      // highlight-crop-ratios

      // By default the editor allows to use a free crop ratio.
      // For this example this is disabled to ensure that the image
      // has a suitable ratio.
      // highlight-free-crop
      options.allowFreeCrop = false;
      // highlight-free-crop

      // By default the editor shows the reset button which resets
      // the applied transform operations. In this example the button
      // is hidden since we are enforcing certain ratios and the user
      // can only select among them anyway.
      // highlight-reset-button
      options.showResetButton = false;
      // highlight-reset-button
    }];

    // Configure the `PESDKPhotoEditViewController`.
    [builder configurePhotoEditViewController:^(PESDKPhotoEditViewControllerOptionsBuilder * _Nonnull options) {
      // For this example the user is forced to crop the asset to one of
      // the allowed crop aspects specified above, before being able to use other
      // features of the editor. The transform tool will only be presented
      // if the image does not already fit one of those allowed aspect ratios.
      // highlight-force-crop
      options.forceCropMode = true;
      // highlight-force-crop
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
