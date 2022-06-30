#import "VideoTextDesignConfiguration.h"
@import VideoEditorSDK;

@interface VideoTextDesignConfigurationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoTextDesignConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the `PESDKTextDesignToolController` that lets the user
    // add text designs to the video.
    [builder configureTextDesignToolController:^(PESDKTextDesignToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor allows to add emojis as text input.
      // Since emojis are not cross-platform compatible, using the serialization
      // feature to share edits across different platforms will result in emojis
      // being rendered with the system's local set of emojis and therefore will
      // appear differently.
      // For this example emoji input is disabled to ensure a consistent cross-platform experience.
      // highlight-emojis
      options.emojisEnabled = false;
      // highlight-emojis

      // By default the editor provides a `PESDKColorPalette` with a lot of colors.
      // For this example this will be replaced with a `ColorPalette`
      // with only a few colors enabled.
      // highlight-color
      options.colorPalette = [[PESDKColorPalette alloc] initWithColors:@[
        [[PESDKColor alloc] initWithColor:UIColor.whiteColor colorName:@"White"],
        [[PESDKColor alloc] initWithColor:UIColor.blackColor colorName:@"Black"]
      ]];
      // highlight-color
    }];

    // Configure the `PESDKTextDesignOptionsToolController` that lets the user
    // change text designs that have been placed on top of the video.
    // highlight-actions
    [builder configureTextDesignOptionsToolController:^(PESDKTextDesignOptionsToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor has all available overlay actions for this tool
      // enabled. For this example `TextDesignOverlayActionUndo` and `TextDesignOverlayActionRedo`
      // are removed.
      options.allowedTextDesignOverlayActions = @[@(TextDesignOverlayActionAdd), @(TextDesignOverlayActionBringToFront), @(TextDesignOverlayActionDelete), @(TextDesignOverlayActionInvert)];
    }];
    // highlight-actions
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
