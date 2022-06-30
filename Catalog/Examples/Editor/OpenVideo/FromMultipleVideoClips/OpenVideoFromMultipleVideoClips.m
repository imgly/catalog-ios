#import "OpenVideoFromMultipleVideoClips.h"
@import AVFoundation;
@import VideoEditorSDK;

@interface OpenVideoFromMultipleVideoClipsObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation OpenVideoFromMultipleVideoClipsObjC

- (void)invokeExample {
  // Get the URLs for video files on the local file system. This could be any file within the app bundle
  // or also a file within the documents or temporary folders for example. This example will use
  // files from the app bundle.
  // highlight-setup
  NSURL *firstURL = [NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"];
  NSURL *secondURL = [NSBundle.mainBundle URLForResource:@"test_video" withExtension:@"mp4"];

  // Create `AVAsset`s from above `NSURL`s.
  AVAsset *firstAsset = [AVAsset assetWithURL:firstURL];
  AVAsset *secondAsset = [AVAsset assetWithURL:secondURL];

  // Create a `PESDKVideo` from above assets.
  PESDKVideo *video = [[PESDKVideo alloc] initWithAssets:@[firstAsset, secondAsset]];
  // highlight-setup

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create a video editor and pass it the video and configuration. Make this class the delegate of it to handle export and cancelation.
  // highlight-instantiation
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
  videoEditViewController.delegate = self;
  // highlight-instantiation

  // Present the video editor.
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
