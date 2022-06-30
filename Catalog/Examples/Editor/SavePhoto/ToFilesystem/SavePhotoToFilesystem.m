#import "SavePhotoToFilesystem.h"
@import MobileCoreServices;
@import PhotoEditorSDK;
@import UniformTypeIdentifiers;

@interface SavePhotoToFilesystemObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation SavePhotoToFilesystemObjC

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

// highlight-photo-export-delegate
- (void)photoEditViewControllerDidFinish:(PESDKPhotoEditViewController * _Nonnull)photoEditViewController result:(PESDKPhotoEditorResult * _Nonnull)result {
  // highlight-photo-export-delegate
  // After the output image is done processing, this delegate method will be called.
  //
  // The `result.output.data` attribute will contain the output image data, including all EXIF information in the format specified in your editor's configuration.
  //
  // If *no modifications* have been made to the image and the `PESDKPhoto` object that was passed to the editor's initializer
  // was created using `-[PESDKPhoto initWithData:]` or `-[PESDKPhoto initWithURL:]` we will not process the image at all
  // and simply forward it to this delegate method. If the `PESDKPhoto` object that was passed to the editor's initializer
  // was created using `-[PESDKPhoto initWithImage:]`, it will be processed and returned in the format specified in your editor's configuration.
  //
  // You can set `PESDKPhotoEditViewControllerOptions.forceExport` to `YES` in which case the image will be passed through our
  // rendering pipeline in any case, even without any modifications applied.

  // highlight-save-photo
  if (result.output.uti == nil) { return; }
  UTType *type = [UTType typeWithIdentifier:result.output.uti];
  if (type == nil) { return; }

  // Get a reference to the temporary directory and append the filename and extension.
  NSURL *temporaryDirectoryURL = NSFileManager.defaultManager.temporaryDirectory;
  // Append a random filename with an extension matching the output format's UTI.
  NSURL *localURL = [temporaryDirectoryURL URLByAppendingPathComponent:[[[NSUUID alloc] init] UUIDString] conformingToType:type];

  if ([NSFileManager.defaultManager fileExistsAtPath:localURL.path]) {
    // Remove the file at the destination if it already exists
    [NSFileManager.defaultManager removeItemAtURL:localURL error:nil];
  }

  // Write image data to `localURL`.
  [result.output.data writeToURL:localURL atomically:YES];
  // highlight-save-photo

  // You can now use `localURL` for further processing. Dismissing the editor now.
  NSLog(@"Saved image at %@", localURL);
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
