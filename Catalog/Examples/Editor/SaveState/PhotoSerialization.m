#import "PhotoSerialization.h"
@import PhotoEditorSDK;

@interface PhotoSerializationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoSerializationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  // highlight-setup
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration];
  photoEditViewController.delegate = self;
  photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];
  // highlight-setup
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

  // To get an `NSData` object of all edits which have been applied to an image, you can use the following method.
  // You can decide whether the serialized settings should also contain the JPEG-encoded image data or not.
  // highlight-serialization
  NSData *serializedSettings = [photoEditViewController serializedSettingsWithImageData:NO];

  // Optionally, you can convert the serialized settings to a JSON string if needed.
  NSString *jsonString = [[NSString alloc] initWithData:serializedSettings encoding:NSUTF8StringEncoding];
  NSLog(@"%@", jsonString);

  // Or to an `NSDictionary`.
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:serializedSettings options:0 error:nil];
  NSLog(@"%@", jsonDict);
  // highlight-serialization

  // You can use either `serializedSettings`, `jsonString`, or `jsonDict` for further processing, such as
  // uploading it to a remote URL or saving it to the filesystem. See `SavePhotoToRemoteURLObjC` or
  // `SavePhotoToFilesystemObjC` to get an idea about the approach to take for this.

  // For loading serialized settings into the editor, please take a look at `PhotoDeserializationObjC`.

  // Dismiss the editor.
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
