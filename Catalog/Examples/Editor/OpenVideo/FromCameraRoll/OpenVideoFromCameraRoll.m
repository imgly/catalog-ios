#import "OpenVideoFromCameraRoll.h"
@import AVFoundation;
@import UniformTypeIdentifiers;
@import VideoEditorSDK;

@interface OpenVideoFromCameraRollObjC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PESDKVideoEditViewControllerDelegate>

@end

@implementation OpenVideoFromCameraRollObjC

- (void)invokeExample {
  // We recommend using the old `UIImagePickerController` class instead of the newer `PHPickerViewController`
  // due to video import issues for some MP4 files encoded with non-ffmpeg codecs. We've filed a bug report
  // with Apple regarding this issue.
  // highlight-instantiate-picker
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.delegate = self;
  imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  imagePicker.mediaTypes = @[UTTypeMovie.identifier];
  // highlight-instantiate-picker

  // Setting `videoExportPreset` to passthrough will not reencode the video before passing it to
  // the delegate methods.
  // highlight-passthrough
  imagePicker.videoExportPreset = AVAssetExportPresetPassthrough;
  // highlight-passthrough

  // Present the image picker modally.
  imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// highlight-imagepicker-delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
  // Dismiss the image picker and present the video editor after dismissal is done
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    // Create a `PESDKVideo` from the picked video URL
    PESDKVideo *video = [[PESDKVideo alloc] initWithURL:info[UIImagePickerControllerMediaURL]];

    // Create a default `PESDKConfiguration`.
    PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

    // Create a video editor and pass it the video and configuration. Make this class the delegate of it to handle export and cancelation.
    PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
    videoEditViewController.delegate = self;

    // Present the video editor.
    videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
  }];
}
// highlight-imagepicker-delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
