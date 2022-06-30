#import "VideoDeserialization.h"
@import VideoEditorSDK;

@interface VideoDeserializationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoDeserializationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a default `PESDKConfiguration` with default `PESDKAssetCatalog`.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    builder.assetCatalog = [PESDKAssetCatalog defaultItems];
  }];

  // Load the serialized settings from the app bundle. You could also load this from a remote URL for example.
  // See `OpenVideoFromRemoteURLObjC` to get an idea about the approach to take for this.
  // highlight-load-settings
  NSData *serializedSettings = [NSData dataWithContentsOfURL:[NSBundle.mainBundle URLForResource:@"video_serialization" withExtension:@"json"]];
  // highlight-load-settings

  // Deserialize the serialized settings. If you're not sure that the aspect ratio of the current video and the
  // video used when creating the serialized settings are identical, you should specify the size of the video to
  // apply the edits on.
  // highlight-deserialize
  PESDKDeserializationResult *deserializationResult = [PESDKDeserializer deserializeWithData:serializedSettings imageDimensions:video.size assetCatalog:configuration.assetCatalog];

  // Get the `PESDKPhotoEditModel` from the deserialization result.
  PESDKPhotoEditModel *photoEditModel = deserializationResult.model;

  // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
  // Pass the deserialized `PESDKPhotoEditModel` to the editor.
  PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration photoEditModel:photoEditModel];
  // highlight-deserialize
  videoEditViewController.delegate = self;
  videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];

  // For saving edits, please take a look at `VideoSerializationObjC`.
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
