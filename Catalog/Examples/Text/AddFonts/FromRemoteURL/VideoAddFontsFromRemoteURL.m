#import "VideoAddFontsFromRemoteURL.h"
@import VideoEditorSDK;

@interface VideoAddFontsFromRemoteURLObjC () <PESDKVideoEditViewControllerDelegate>

// Save a reference to the downloaded file to remove it when done.
@property (nonatomic, nullable, strong) NSURL *localURL;

@end

@implementation VideoAddFontsFromRemoteURLObjC
// Although the editor supports adding assets with remote URLs, we highly recommend
// that you manage the download of remote resources yourself, since this
// gives you more control over the whole process. After successfully downloading
// the files you should pass the local URLs to the asset catalog of the configuration.
- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Download the custom font.
  // highlight-download
  NSURL *remoteURL = [NSURL URLWithString:@"https://img.ly/static/example-assets/custom_font_raleway_regular.ttf"];

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
      // highlight-download

      // Dispatch to the main queue for any UI work
      // and to prevent race conditions.
      // highlight-queue
      dispatch_async(dispatch_get_main_queue(), ^{
        self.localURL = localURL;
      // highlight-queue

        // Create a reference to the custom font.
        // highlight-object
        PESDKFont *customFont = [[PESDKFont alloc] initWithUrl:localURL displayName:@"Raleway" fontName:@"custom_font_raleway_regular" identifier:@"custom_font_raleway_regular"];

        // Create a reference to a system font.
        PESDKFont *systemFont = [[PESDKFont alloc] initWithDisplayName:@"Helvetica" fontName:@"Helvetica" identifier:@"system_font_helvetica"];
        // highlight-object

        // Create a default `PESDKConfiguration`.
        PESDKConfiguration *configuration = [[PESDKConfiguration alloc] initWithBuilder:^(PESDKConfigurationBuilder * _Nonnull builder) {
          // In this example we are using the default assets for the asset catalog as a base.
          // However, you can also create an empty catalog as well which only contains your
          // custom assets.
          // highlight-catalog
          PESDKAssetCatalog *assetCatalog = PESDKAssetCatalog.defaultItems;

          // Add the custom fonts to the asset catalog.
          assetCatalog.fonts = [assetCatalog.fonts arrayByAddingObjectsFromArray:@[customFont, systemFont]];

          // Use the new asset catalog for the configuration.
          builder.assetCatalog = assetCatalog;
          // highlight-catalog
        }];

        // Create a video editor and pass it the video and configuration. Make this class the delegate of it to handle export and cancelation.
        PESDKVideoEditViewController *videoEditViewController = [[PESDKVideoEditViewController alloc] initWithVideoAsset:video configuration:configuration];
        videoEditViewController.delegate = self;

        // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
        self.presentingViewController.view.userInteractionEnabled = YES;

        // Present the video editor.
        videoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.presentingViewController presentViewController:videoEditViewController animated:YES completion:nil];
      });
    }
  }];

  // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
  self.presentingViewController.view.userInteractionEnabled = NO;

  // Start the file download
  [downloadTask resume];
}

// Removes the previously downloaded resources.
- (void)removeResources {
  [NSFileManager.defaultManager removeItemAtURL:self.localURL error:nil];
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
