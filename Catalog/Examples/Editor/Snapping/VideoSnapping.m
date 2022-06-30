#import "VideoSnapping.h"
@import VideoEditorSDK;

@interface VideoSnappingObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoSnappingObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Configure the snapping of all sprites globally in the editor.
    //
    // For this example the editor's snapping behavior is configured
    // to act as a guide for the user to see where the sprites should
    // be placed. A use case could be that an application displays
    // the videos both in rectangular as well as in circular
    // shapes which requires the editor to indicate where the area
    // is in which sprites' visibility is best.
    [builder configureSnapping:^(PESDKSnappingOptionsOptionsBuilder * _Nonnull options) {
      // By default the snapping is enabled when rotating a sprite.
      // For this example this behavior is disabled since only the
      // outer positional snapping guides are needed.
      // highlight-rotation
      options.rotationSnappingEnabled = false;
      // highlight-rotation

      // By default the center of the sprite snaps to a vertical
      // line indicating the center of the video.
      // For this example this behavior is disabled since only the
      // outer positional snapping guides are needed.
      // highlight-vertical-line
      options.snapToVerticalCenterLine = false;
      // highlight-vertical-line

      // By default the center of the sprite snaps to a horizontal
      // line indicating the center of the video.
      // For this example this behavior is disabled since only the
      // outer positional snapping guides are needed.
      // highlight-horizontal-line
      options.snapToHorizontalCenterLine = false;
      // highlight-horizontal-line

      // By default the sprite snaps to a horizontal line
      // on the bottom of the video. This value is measured in normalized
      // coordinates relative to the smaller side of the edited video and
      // defaults to 10% (0.1).
      // For this example the value is set to 15% (0.15) to define the
      // visibility area of the video.
      // highlight-positional
      options.snapToBottom = @(0.15);

      // By default the sprite snaps to a horizontal line
      // on the top of the video. This value is measured in normalized
      // coordinates relative to the smaller side of the edited video and
      // defaults to 10% (0.1).
      // For this example the value is set to 15% (0.15) to define the
      // visibility area of the video.
      options.snapToTop = @(0.15);

      // By default the sprite snaps to a vertical line
      // on the left of the video. This value is measured in normalized
      // coordinates relative to the smaller side of the edited video and
      // defaults to 10% (0.1).
      // For this example the value is set to 15% (0.15) to define the
      // visibility area of the video.
      options.snapToLeft = @(0.15);

      // By default the sprite snaps to a vertical line
      // on the right of the video. This value is measured in normalized
      // coordinates relative to the smaller side of the edited video and
      // defaults to 10% (0.1).
      // For this example the value is set to 15% (0.15) to define the
      // visibility area of the video.
      options.snapToRight = @(0.15);
      // highlight-positional
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
