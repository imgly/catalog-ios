#import "VideoTextConfiguration.h"
@import VideoEditorSDK;

@interface VideoTextConfigurationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoTextConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKTextToolController` which lets the user
    // add text to the video.
    [builder configureTextToolController:^(PESDKTextToolControllerOptionsBuilder * _Nonnull options) {
      // By default the text alignment is set to `NSTextAlignmentCenter`.
      // In this example, the default text orientation is set to `NSTextAlignmentLeft`.
      // highlight-text-align
      options.defaultTextAlignment = NSTextAlignmentLeft;
      // highlight-text-align

      // By default the editor allows to add emojis as text input.
      // Since emojis are not cross-platform compatible, using the serialization
      // feature to share edits across different platforms will result in emojis
      // being rendered with the system's local set of emojis and therefore will
      // appear differently.
      // For this example emoji input is disabled to ensure a consistent cross-platform experience.
      // highlight-emojis
      options.emojisEnabled = false;
      // highlight-emojis

      // By default the minimum text size is set to 20pt.
      // For this example the minimum size is reduced.
      // highlight-size
      options.minimumTextSize = 17.0;
      // highlight-size
    }];

    // Configure the `PESDKTextFontToolController` which lets the user
    // change the font of the text.
    [builder configureTextFontToolController:^(PESDKTextFontToolControllerOptionsBuilder * _Nonnull options) {
      // This closure is executed every time the user selects a font.
      // highlight-font-selection
      options.textFontActionSelectedClosure = ^(NSString * _Nonnull fontName) {
        NSLog(@"Font has been selected with name: %@", fontName);
      };
      // highlight-font-selection
    }];

    // Configure the `PESDKTextColorToolController` which lets the user
    // change the color of the text.
    [builder configureTextColorToolController:^(PESDKTextColorToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor provides a variety of different
      // colors to customize the color of the text.
      // For this example only a small selection of colors is shown by default
      // e.g. based on favorite colors of the user.
      // highlight-colors
      options.availableColors = @[
        [[PESDKColor alloc] initWithColor:UIColor.whiteColor colorName:@"White"],
        [[PESDKColor alloc] initWithColor:UIColor.blackColor colorName:@"Black"],
      ];
      // highlight-colors

      // By default the editor provides a variety of different
      // colors to customize the background color of the text.
      // For this example only a small selection of colors is shown by default
      // e.g. based on favorite colors of the user.
      // highlight-background-colors
      options.availableBackgroundTextColors = @[
        [[PESDKColor alloc] initWithColor:UIColor.redColor colorName:@"Red"],
        [[PESDKColor alloc] initWithColor:UIColor.greenColor colorName:@"Green"],
        [[PESDKColor alloc] initWithColor:UIColor.yellowColor colorName:@"Yellow"]
      ];
      // highlight-background-colors
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
