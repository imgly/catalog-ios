#import "OpenPhotoFromCameraRoll.h"
@import AVFoundation;
@import UniformTypeIdentifiers;
@import PhotoEditorSDK;

@interface OpenPhotoFromCameraRollObjC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PESDKPhotoEditViewControllerDelegate>

@end

@implementation OpenPhotoFromCameraRollObjC

- (void)invokeExample {
  // We recommend using the old `UIImagePickerController` class instead of the newer `PHPickerViewController`
  // due to video import issues for some MP4 files encoded with non-ffmpeg codecs. We've filed a bug report
  // with Apple regarding this issue. If you do not require support for video files, feel free to use
  // `PHPickerViewController`.
  // highlight-instantiate-picker
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.delegate = self;
  imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  imagePicker.mediaTypes = @[UTTypeImage.identifier];
  // highlight-instantiate-picker

  // Present the image picker modally.
  imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

// highlight-imagepicker-delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
  // Dismiss the image picker and present the photo editor after dismissal is done
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    // Create a `PESDKPhoto` from the picked photo.
    PESDKPhoto *photo = [[PESDKPhoto alloc] initWithImage:info[UIImagePickerControllerOriginalImage]];

    // Create a default `PESDKConfiguration`.
    PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

    // Create a photo editor and pass it the photo and configuration. Make this class the delegate of it to handle export and cancelation.
    PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration];
    photoEditViewController.delegate = self;

    // Present the photo editor.
    photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];
  }];
}
// highlight-imagepicker-delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
