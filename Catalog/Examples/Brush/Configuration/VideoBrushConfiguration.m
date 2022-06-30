#import "VideoBrushConfiguration.h"
@import VideoEditorSDK;

@interface VideoBrushConfigurationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoBrushConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKBrushToolController` which lets the user
    // draw on the video.
    [builder configureBrushToolController:^(PESDKBrushToolControllerOptionsBuilder * _Nonnull options) {
      // By default all available brush tools are enabled.
      // For this example only a couple are enabled.
      // highlight-tools
      options.allowedBrushTools = @[@(BrushToolColor), @(BrushToolSize)];
      // highlight-tools

      // By default the default color for the brush stroke is
      // `UIColor.whiteColor`. For this example the default color
      // is set to `UIColor.blackColor`.
      // highlight-color
      options.defaultBrushColor = UIColor.blackColor;
      // highlight-color

      // By default the default brush size is set to 5% of the
      // smaller side of the video.
      // For this example the default size should be absolute.
      // highlight-size
      options.defaultBrushSize = [[PESDKFloatValue alloc] initWithAbsoluteValue:5];
      // highlight-size
    }];

    // Configure the `PESDKBrushColorToolController` which lets the user
    // change the color of the brush stroke.
    [builder configureBrushColorToolController:^(PESDKBrushColorToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor provides a variety of different
      // colors to customize the color of the brush stroke.
      // For this example only a small selection of colors is enabled.
      // highlight-colors
      options.availableColors = @[
        [[PESDKColor alloc] initWithColor:UIColor.whiteColor colorName:@"White"],
        [[PESDKColor alloc] initWithColor:UIColor.blackColor colorName:@"Black"],
        [[PESDKColor alloc] initWithColor:UIColor.redColor colorName:@"Red"]
      ];
      // highlight-colors
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

