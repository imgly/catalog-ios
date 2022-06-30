#import "VideoAddFiltersFromRemoteURL.h"
@import VideoEditorSDK;

@interface VideoAddFiltersFromRemoteURLObjC () <PESDKVideoEditViewControllerDelegate>

// The local locations of the downloaded remote resources.
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSURL*> *downloadLocations;

@end

@implementation VideoAddFiltersFromRemoteURLObjC

// Although the editor supports adding assets with remote URLs, we highly recommend
// that you manage the download of remote resources yourself, since this
// gives you more control over the whole process. After successfully downloading
// the files you should pass the local URLs to the asset catalog of the configuration.
- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Filenames of remote assets.
  // highlight-download
  NSString *filterFilename = @"custom_lut_invert.png";
  NSString *thumbnailFilename = @"custom_filter_category.jpg";

  // All available filenames of the assets.
  NSArray<NSString *> *assetFilenames = @[filterFilename, thumbnailFilename];

  // Create the empty download locations dictionary.
  self.downloadLocations = [NSMutableDictionary dictionary];

  // Download each of the remote resources.
  for (NSString *filename in assetFilenames) {
    NSString *remoteResource = [NSString stringWithFormat:@"https://img.ly/static/example-assets/%@", filename];
    NSURL *remoteURL = [NSURL URLWithString:remoteResource];
    NSURLSessionDownloadTask *downloadTask = [NSURLSession.sharedSession downloadTaskWithURL:remoteURL completionHandler:^(NSURL * _Nullable downloadURL, NSURLResponse * _Nullable response, NSError * _Nullable error) {
      if (error != nil) {
        [NSException raise:@"Error downloading file" format:@"There was an error downloading the file: %@", error.description];
        return;
      }

      if (downloadURL != nil) {
        // File was downloaded successfully. Saving it in the temporary directory.
        NSURL *temporaryDirectoryURL = NSFileManager.defaultManager.temporaryDirectory;
        NSURL *localURL = [temporaryDirectoryURL URLByAppendingPathComponent:filename];

        if ([NSFileManager.defaultManager fileExistsAtPath:localURL.path]) {
          // Remove the file at the destination if it already exists
          [NSFileManager.defaultManager removeItemAtURL:localURL error:nil];
        }
        [NSFileManager.defaultManager moveItemAtURL:downloadURL toURL:localURL error:nil];
        // highlight-download

        // Dispatch to the main queue for any UI work
        // and to prevent race conditions.
        // highlight-queue
        dispatch_async(dispatch_get_main_queue(), ^{
          self.downloadLocations[filename] = localURL;
          // highlight-queue

          // If all resources have been downloaded the editor can be started.
          // highlight-object
          if (self.downloadLocations.count == assetFilenames.count) {
            // Create a custom LUT filter from the downloaded resources.
            NSURL *filterURL = self.downloadLocations[filterFilename];
            PESDKEffect *customLUTFilter = [[PESDKLUTEffect alloc] initWithIdentifier:@"custom_lut_filter" lutURL:filterURL displayName:@"Invert" horizontalTileCount:5 verticalTileCount:5];

            // Create a custom DuoTone filter.
            PESDKEffect *customDuoToneFilter = [[PESDKDuoToneEffect alloc] initWithIdentifier:@"custom_duotone_filter" lightColor:UIColor.yellowColor darkColor:UIColor.blueColor displayName:@"Custom"];
            // highlight-object

            // Create a default `PESDKConfiguration`.
            PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
              // In this example we are using the default assets for the asset catalog as a base.
              // However, you can also create an empty catalog as well which only contains your
              // custom assets.
              // highlight-catalog
              PESDKAssetCatalog *assetCatalog = PESDKAssetCatalog.defaultItems;

              // Add the custom filters to the asset catalog.
              assetCatalog.effects = [assetCatalog.effects arrayByAddingObjectsFromArray:@[customLUTFilter, customDuoToneFilter]];

              // Use the new asset catalog for the configuration.
              builder.assetCatalog = assetCatalog;
              // highlight-catalog

              // Optionally, you can create custom filter groups which group
              // multiple filters into one folder in the filter tool. If you do not
              // create filter groups the filters will appear independent of each
              // other.
              //
              // Create the thumbnail for the filter group from the downloaded resources.
              // highlight-group
              NSURL *thumbnailURL = self.downloadLocations[thumbnailFilename];
              NSData *thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
              UIImage *thumbnail = [UIImage imageWithData:thumbnailData];

              // Create the actual filter group.
              PESDKGroup *customFilterGroup = [[PESDKGroup alloc] initWithIdentifier:@"custom_filter_category" displayName:@"Custom" thumbnail:thumbnail memberIdentifiers:@[@"custom_lut_filter"]];

              // Add the custom filter group to the filter tool.
              [builder configureFilterToolController:^(PESDKFilterToolControllerOptionsBuilder * _Nonnull options) {
                options.filterGroups = [options.filterGroups arrayByAddingObject:customFilterGroup];
              }];
              // highlight-group
            }];

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
