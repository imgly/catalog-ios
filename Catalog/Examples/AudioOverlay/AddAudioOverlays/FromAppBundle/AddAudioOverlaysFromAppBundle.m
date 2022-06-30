#import "AddAudioOverlaysFromAppBundle.h"
@import VideoEditorSDK;

@interface AddAudioOverlaysFromAppBundleObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation AddAudioOverlaysFromAppBundleObjC

- (void)invokeExample {
   // Create a `PESDKVideo` from a URL to a video in the app bundle.
   PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

   // Identifiers of audio clips in the app bundle.
   // highlight-load-clips
   NSArray<NSString *> *elsewhereAudioClipIdentifiers = @[
     @"elsewhere",
     @"trapped_in_the_upside_down"
   ];
   NSArray<NSString *> *otherAudioClipIdentifiers = @[
     @"dance_harder",
     @"far_from_home"
   ];

   // Create new audio clip categories with custom audio clips from
   // the app bundle.
   NSMutableArray<PESDKAudioClip *> *elsewhereClips = [NSMutableArray array];
   [elsewhereAudioClipIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     NSURL *url = [NSBundle.mainBundle URLForResource:obj withExtension:@".mp3"];
     PESDKAudioClip *audioClip = [[PESDKAudioClip alloc] initWithIdentifier:obj audioURL:url];
     [elsewhereClips addObject:audioClip];
   }];
   NSMutableArray<PESDKAudioClip *> *otherClips = [NSMutableArray array];
   [otherAudioClipIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     NSURL *url = [NSBundle.mainBundle URLForResource:obj withExtension:@".mp3"];
     PESDKAudioClip *audioClip = [[PESDKAudioClip alloc] initWithIdentifier:obj audioURL:url];
     [otherClips addObject:audioClip];
   }];
   // highlight-load-clips

   // highlight-categories
   PESDKAudioClipCategory *elswhereAudioClipCategory = [[PESDKAudioClipCategory alloc] initWithTitle:@"Elsewhere" imageURL:nil audioClips:elsewhereClips];
   PESDKAudioClipCategory *otherAudioClipCategory = [[PESDKAudioClipCategory alloc] initWithTitle:@"Other" imageURL:nil audioClips:otherClips];
   // highlight-categories

   // Create a `PESDKConfiguration` object.
   // highlight-configure
   PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
     // In this example we are using the default assets for the asset catalog as a base.
     // However, you can also create an empty catalog as well which only contains your
     // custom assets.
     PESDKAssetCatalog *assetCatalog = [PESDKAssetCatalog defaultItems];

     // Add the custom audio clips to the asset catalog.
     assetCatalog.audioClips = @[elswhereAudioClipCategory, otherAudioClipCategory];

     // Use the new asset catalog for the configuration.
     builder.assetCatalog = assetCatalog;
   }];
   // highlight-configure

   // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
   PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
   videoEditViewController.delegate = self;
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
