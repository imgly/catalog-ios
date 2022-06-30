#import "PhotoDeserialization.h"
@import PhotoEditorSDK;

@interface PhotoDeserializationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoDeserializationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a default `PESDKConfiguration` with default `PESDKAssetCatalog`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    builder.assetCatalog = [PESDKAssetCatalog defaultItems];
  }];

  // Load the serialized settings from the app bundle. You could also load this from a remote URL for example.
  // See `OpenPhotoFromRemoteURLObjC` to get an idea about the approach to take for this.
  // highlight-load-settings
  NSData *serializedSettings = [NSData dataWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"photo_serialization" withExtension:@"json"]];
  // highlight-load-settings

  // Deserialize the serialized settings. If the photo was not serialized along with the edits or you're not sure
  // that the aspect ratio of the current photo and the photo used when creating the serialized settings are identical,
  // you should specify the size of the photo to apply the edits on.
  // highlight-deserialize
  PESDKDeserializationResult *deserializationResult = [PESDKDeserializer deserializeWithData:serializedSettings imageDimensions:photo.size assetCatalog:configuration.assetCatalog];

  // Get the `PESDKPhotoEditModel` from the deserialization result.
  PESDKPhotoEditModel *photoEditModel = deserializationResult.model;

  // If the original photo was serialized along with the edits, you could receive it from the deserialization
  // result like this.
  // PESDKPhoto *photo = [PESDKPhoto photoFromPhotoRepresentation:deserializationResult.photo];

  // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
  // Pass the deserialized `PESDKPhotoEditModel` to the editor.
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration photoEditModel:photoEditModel];
  // highlight-deserialize
  photoEditViewController.delegate = self;
  photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];

  // For saving edits, please take a look at `PhotoSerializationObjC`.
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
