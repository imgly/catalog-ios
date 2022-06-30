#import "SaveVideoToCameraRoll.h"
@import Photos;
@import VideoEditorSDK;

@interface SaveVideoToCameraRollObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation SaveVideoToCameraRollObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  // highlight-setup
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
  videoEditViewController.delegate = self;
  videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
  // highlight-setup
}

#pragma mark - PESDKVideoEditViewControllerDelegate

- (BOOL)videoEditViewControllerShouldStart:(PESDKVideoEditViewController * _Nonnull)videoEditViewController task:(PESDKVideoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

// highlight-video-export-delegate
- (void)videoEditViewControllerDidFinish:(PESDKVideoEditViewController * _Nonnull)videoEditViewController result:(PESDKVideoEditorResult * _Nonnull)result {
  // highlight-video-export-delegate
  // The user exported a new video successfully and the newly generated video is located at `result.output.url`.
  // If **no modifications** have been made to the original video, we will not process the original video at all
  // and also not reencode it. In this case `result.output.url` will point to the original video that was passed to the editor,
  // if available. If you want to ensure that the original video is always reencoded, even if no modifications have
  // been made to it, you can set `PESDKVideoEditViewControllerOptions.forceExport` to `YES`, in which case `result.output.url` will
  // always point to a newly generated video.

  // Request access to save to the user's camera roll.
  // highlight-request-authorization
  [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
    if (status != PHAuthorizationStatusAuthorized) {
      // Authorization hasn't been granted. In production you could now for example show an alert asking the user
      // to open their Settings.app to grant permissions. Dismissing the editor.
      NSLog(@"Authorization to write to the camera roll has not been granted.");
      [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
      return;
    }
    // highlight-request-authorization

    // Perform changes in the shared photo library.
    // highlight-move-video
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
      // Create a `PHAssetCreationRequest`.
      PHAssetCreationRequest *assetCreationRequest = [PHAssetCreationRequest creationRequestForAsset];

      // Move the video file instead of copying if possible, so that we don't have to delete it manually.
      // If you wish to keep the original file, you don't need this.
      // If the video wasn't modified, we won't move the file.
      // In production this check would not be needed because the app bundle is read-only.
      // Unfortunately, with the Simulator it is not read-only so we need to include this check
      // or the example will crash when opened a second time.
      PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
      if (result.status != VESDKVideoEditorStatusPassedWithoutRendering) {
        options.shouldMoveFile = YES;
      }

      // Add the video file.
      [assetCreationRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:result.output.url options:options];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
      // highlight-move-video
      // highlight-completion
      if (success) {
        NSLog(@"Successfully saved video to camera roll.");
      } else {
        NSLog(@"Error saving video to camera roll: %@", error);
      }

      // Dispatching to the main queue and dismissing the editor.
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
      });
      // highlight-completion
    }];
  }];
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
