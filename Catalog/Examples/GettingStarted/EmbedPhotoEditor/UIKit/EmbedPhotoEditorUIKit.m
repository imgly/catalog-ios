#import "EmbedPhotoEditorUIKit.h"
@import PhotoEditorSDK;

@interface EmbedPhotoEditorUIKitObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation EmbedPhotoEditorUIKitObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a default `PESDKConfiguration`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

  // Create the photo editor. Make this class the delegate of it to handle export and cancelation.
  // highlight-create-editor
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration];
  photoEditViewController.delegate = self;
  // highlight-create-editor

  // Create and present a navigation controller that hosts the photo editor.
  // The photo editor will now use the navigation controller's navigation bar for its cancel and save
  // buttons instead of its own toolbar.
  // If the photo editor is the navigation controller's root view controller, it will display the close
  // button on the left side of the navigation bar and call `photoEditViewControllerDidCancel(_:)` when
  // the user taps on it.
  // If the photo editor is *not* the navigation controller's root view controller, it will display the
  // regular back button on the left side of the navigation bar and will *not* call
  // `photoEditViewControllerDidCancel(_:)` when tapping on it.
  // highlight-embed
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photoEditViewController];
  navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:navigationController animated:YES completion:nil];
  // highlight-embed
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
