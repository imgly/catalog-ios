#import "VideoTransformConfiguration.h"
@import VideoEditorSDK;

@interface VideoTransformConfigurationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoTransformConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];
  
  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKTransformToolController` that lets the user
    // crop and rotate the video.
    [builder configureTransformToolController:^(PESDKTransformToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor has a lot of crop aspects enabled.
      // For this example only a couple are enabled, e.g. if you
      // only allow certain video aspects in your application.
      // highlight-crop-ratios
      options.allowedCropRatios = @[
        [[PESDKCropAspect alloc] initWithWidth:1 height:1],
        [[PESDKCropAspect alloc] initWithWidth:16 height:9 localizedName:@"Landscape"],
      ];
      // highlight-crop-ratios

      // By default the editor allows to use a free crop ratio.
      // For this example this is disabled to ensure that the video
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

    // Configure the `PESDKVideoEditViewController`.
    [builder configureVideoEditViewController:^(PESDKVideoEditViewControllerOptionsBuilder * _Nonnull options) {
      // For this example the user is forced to crop the asset to one of
      // the allowed crop aspects specified above, before being able to use other
      // features of the editor. The transform tool will only be presented
      // if the video does not already fit one of those allowed aspect ratios.
      // highlight-force-crop
      options.forceCropMode = true;
      // highlight-force-crop
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
