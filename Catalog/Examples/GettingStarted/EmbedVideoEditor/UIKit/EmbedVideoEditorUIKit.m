#import "EmbedVideoEditorUIKit.h"
@import VideoEditorSDK;

@interface EmbedVideoEditorUIKitObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation EmbedVideoEditorUIKitObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create the video editor. Make this class the delegate of it to handle export and cancelation.
  // highlight-create-editor
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
  videoEditViewController.delegate = self;
  // highlight-create-editor

  // Create and present a navigation controller that hosts the video editor.
  // The video editor will now use the navigation controller's navigation bar for its cancel and save
  // buttons instead of its own toolbar.
  // If the video editor is the navigation controller's root view controller, it will display the close
  // button on the left side of the navigation bar and call `videoEditViewControllerDidCancel(_:)` when
  // the user taps on it.
  // If the video editor is *not* the navigation controller's root view controller, it will display the
  // regular back button on the left side of the navigation bar and will *not* call
  // `videoEditViewControllerDidCancel(_:)` when tapping on it.
  // highlight-embed
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:videoEditViewController];
  navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:navigationController animated:YES completion:nil];
  // highlight-embed
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
