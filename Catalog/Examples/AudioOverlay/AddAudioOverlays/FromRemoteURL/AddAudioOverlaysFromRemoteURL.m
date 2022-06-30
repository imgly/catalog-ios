#import "AddAudioOverlaysFromRemoteURL.h"
@import VideoEditorSDK;

@interface AddAudioOverlaysFromRemoteURLObjC () <PESDKVideoEditViewControllerDelegate>

// The local locations of the downloaded remote resources.
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSURL*> *downloadLocations;

@end

@implementation AddAudioOverlaysFromRemoteURLObjC

// Although the editor supports adding assets with remote URLs, we highly recommend
// that you manage the download of remote resources yourself, since this
// gives you more control over the whole process. After successfully downloading
// the files you should pass the local URLs to the asset catalog of the configuration.
- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to an image in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Identifiers of remote audio clips.
  // highlight-start-download
  NSArray<NSString *> *elsewhereAudioClipIdentifiers = @[
    @"elsewhere",
    @"trapped_in_the_upside_down"
  ];
  NSArray<NSString *> *otherAudioClipIdentifiers = @[
    @"dance_harder",
    @"far_from_home"
  ];

  // All available identifiers of the audio clips.
  NSArray<NSString *> *audioClipIdentifiers = [elsewhereAudioClipIdentifiers arrayByAddingObjectsFromArray:otherAudioClipIdentifiers];

  // Create the empty download locations dictionary.
  self.downloadLocations = [NSMutableDictionary dictionary];

  // Download each of the remote resources.
  for (NSString *identifier in audioClipIdentifiers) {
    NSString *remoteResource = [NSString stringWithFormat:@"https://img.ly/static/example-assets/%@.mp3", identifier];
    NSURL *remoteURL = [NSURL URLWithString:remoteResource];
    NSURLSessionDownloadTask *downloadTask = [NSURLSession.sharedSession downloadTaskWithURL:remoteURL completionHandler:^(NSURL * _Nullable downloadURL, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      if (error != nil) {
        [NSException raise:@"Error downloading file" format:@"There was an error downloading the file: %@", error.description];
        return;
      }

      if (downloadURL != nil) {
        // File was downloaded successfully. Saving it in the temporary directory.
        NSURL *temporaryDirectoryURL = NSFileManager.defaultManager.temporaryDirectory;
        NSURL *localURL = [temporaryDirectoryURL URLByAppendingPathComponent:remoteURL.lastPathComponent];

        if ([NSFileManager.defaultManager fileExistsAtPath:localURL.path]) {
          // Remove the file at the destination if it already exists
          [NSFileManager.defaultManager removeItemAtURL:localURL error:nil];
        }
        [NSFileManager.defaultManager moveItemAtURL:downloadURL toURL:localURL error:nil];
        // highlight-start-download

        // Dispatch to the main queue for any UI work
        // and to prevent race conditions.
        // highlight-main-queue
        dispatch_async(dispatch_get_main_queue(), ^{
          self.downloadLocations[identifier] = localURL;
          // highlight-main-queue

          // If all resources have been downloaded the editor can be started.
          // highlight-load-clips
          if (self.downloadLocations.count == audioClipIdentifiers.count) {
            // Create new audio clip categories with custom audio clips from
            // the downloaded resources.
            NSMutableArray<PESDKAudioClip *> *elsewhereClips = [NSMutableArray array];
            NSMutableArray<PESDKAudioClip *> *otherClips = [NSMutableArray array];

            [self.downloadLocations enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURL * _Nonnull obj, BOOL * _Nonnull stop) {
              PESDKAudioClip *audioClip = [[PESDKAudioClip alloc] initWithIdentifier:key audioURL:obj];
              if ([elsewhereAudioClipIdentifiers containsObject:key]) {
                [elsewhereClips addObject:audioClip];
              }
              if ([otherAudioClipIdentifiers containsObject:key]) {
                [otherClips addObject:audioClip];
              }
            }];
            // highlight-load-clips

            // highlight-categories
            PESDKAudioClipCategory *elsewhereAudioClipCategory = [[PESDKAudioClipCategory alloc] initWithTitle:@"Elsewhere" imageURL:nil audioClips:elsewhereClips];
            PESDKAudioClipCategory *otherAudioClipCategory = [[PESDKAudioClipCategory alloc] initWithTitle:@"Other" imageURL:nil audioClips:otherClips];
            // highlight-categories

            // Create a `PESDKConfiguration` object.
            // highlight-configure
            PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
              // Add the custom audio clips to the asset catalog.
              builder.assetCatalog.audioClips = @[elsewhereAudioClipCategory, otherAudioClipCategory];
            }];
            // highlight-configure

            // Create a video editor and pass it the video and configuration. Make this class the delegate of it to handle export and cancelation.
            PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
            videoEditViewController.delegate = self;

            // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
            self.presentingViewController.view.userInteractionEnabled = YES;

            // Present the video editor.
            videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
          }
        });
      }
    }];

    // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
    self.presentingViewController.view.userInteractionEnabled = NO;

    // Start the file download
    [downloadTask resume];
  }
}

// Removes the previously downloaded resources.
- (void)removeResources {
  for (NSURL *location in self.downloadLocations.allValues) {
    [NSFileManager.defaultManager removeItemAtURL:location error:nil];
  }
  [self.downloadLocations removeAllObjects];
}

#pragma mark - PESDKVideoEditViewControllerDelegate

- (BOOL)videoEditViewControllerShouldStart:(PESDKVideoEditViewController * _Nonnull)videoEditViewController task:(PESDKVideoEditorTask * _Nonnull)task {
  // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `NO`.
  return YES;
}

 - (void)videoEditViewControllerDidFinish:(PESDKVideoEditViewController * _Nonnull)videoEditViewController result:(PESDKVideoEditorResult * _Nonnull)result {
  // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [self removeResources];
  }];
}

- (void)videoEditViewControllerDidFail:(PESDKVideoEditViewController * _Nonnull)videoEditViewController error:(PESDKVideoEditorError * _Nonnull)error {
  // There was an error generating the video. Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [self removeResources];
  }];
}

- (void)videoEditViewControllerDidCancel:(PESDKVideoEditViewController * _Nonnull)videoEditViewController {
  // The user tapped on the cancel button within the editor. Dismissing the editor.
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    [self removeResources];
  }];
}

@end
