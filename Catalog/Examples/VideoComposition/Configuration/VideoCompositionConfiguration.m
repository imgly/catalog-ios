#import "VideoCompositionConfiguration.h"
@import VideoEditorSDK;

@interface VideoCompositionConfigurationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoCompositionConfigurationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Identifiers of video clips in the app bundle.
  NSArray<NSString *> *miscVideoClipIdentifiers = @[
    @"delivery",
    @"notes"
  ];
  NSArray<NSString *> *peopleVideoClipIdentifiers = @[
    @"dj",
    @"rollerskates"
  ];

  // Create new video clip categories with custom video clips from
  // the app bundle.
  NSMutableArray<PESDKVideoClip *> *miscClips = [NSMutableArray array];
  [miscVideoClipIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSURL *url = [NSBundle.mainBundle URLForResource:obj withExtension:@".mp4"];
    PESDKVideoClip *videoClip = [[PESDKVideoClip alloc] initWithIdentifier:obj videoURL:url];
    [miscClips addObject:videoClip];
  }];
  NSMutableArray<PESDKVideoClip *> *peopleClips = [NSMutableArray array];
  [peopleVideoClipIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSURL *url = [NSBundle.mainBundle URLForResource:obj withExtension:@".mp4"];
    PESDKVideoClip *videoClip = [[PESDKVideoClip alloc] initWithIdentifier:obj videoURL:url];
    [peopleClips addObject:videoClip];
  }];

  PESDKVideoClipCategory *miscVideoClipCategory = [[PESDKVideoClipCategory alloc] initWithTitle:@"Misc" imageURL:nil videoClips:miscClips];
  PESDKVideoClipCategory *peopleVideoClipCategory = [[PESDKVideoClipCategory alloc] initWithTitle:@"People" imageURL:nil videoClips:peopleClips];

  // Create a `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
    // Add the custom audio clips to the asset catalog.
    // highlight-clips
    builder.assetCatalog.videoClips = @[miscVideoClipCategory, peopleVideoClipCategory];
    // highlight-clips

    // Configure the `PESDKCompositionToolController` that lets the user edit
    // the video composition.
    // highlight-actions
    [builder configureCompositionToolController:^(PESDKCompositionToolControllerOptionsBuilder * _Nonnull options) {
      // By default editor presents an image picker for adding video clips
      // to the composition. For this example, the editor should present the
      // `PESDKVideoClipToolController` which lets the user select video clips
      // that have been added to the `PESDKAssetCatalog`.
      options.videoClipLibraryMode = PESDKVideoClipLibraryModePredefined;
    }];
    // highlight-actions

    // Configure the `PESDKVideoClipToolController` that lets the user
    // add videos to the video composition.
    [builder configureVideoClipToolController:^(PESDKVideoClipToolControllerOptionsBuilder * _Nonnull options) {
      // By default the editor selects the first video clip category
      // when opening the selection tool. For this example the editor
      // will select the second category.
      // highlight-category
      options.defaultVideoClipCategoryIndex = 1;
      // highlight-category

      // By default the user is allowed to add personal video clips
      // from the device. For this example the user is only allowed
      // to add video clips that are predefined in the editor configuration.
      // highlight-personal
      options.personalVideoClipsEnabled = false;
      // highlight-personal
    }];
  }];

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
