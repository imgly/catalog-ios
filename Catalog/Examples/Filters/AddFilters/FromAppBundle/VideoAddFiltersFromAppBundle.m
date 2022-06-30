#import "VideoAddFiltersFromAppBundle.h"
@import VideoEditorSDK;

@interface VideoAddFiltersFromAppBundleObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoAddFiltersFromAppBundleObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to a video in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

  // Create a custom LUT filter.
  // highlight-custom-filters
  PESDKEffect *customLUTFilter = [[PESDKLUTEffect alloc] initWithIdentifier:@"custom_lut_filter" lutURL:[NSBundle.mainBundle URLForResource:@"custom_lut_invert" withExtension:@"png"] displayName:@"Invert" horizontalTileCount:5 verticalTileCount:5];

  // Create a custom DuoTone filter.
  PESDKEffect *customDuoToneFilter = [[PESDKDuoToneEffect alloc] initWithIdentifier:@"custom_duotone_filter" lightColor:UIColor.yellowColor darkColor:UIColor.blueColor displayName:@"Custom"];
  // highlight-custom-filters

  // Create a `PESDKConfiguration` object.
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
    // Create the thumbnail for the filter group.
    // highlight-groups
    NSURL *thumbnailURL = [NSBundle.mainBundle URLForResource:@"custom_filter_category" withExtension:@"jpg"];
    NSData *thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
    UIImage *thumbnail = [UIImage imageWithData:thumbnailData];

    // Create the actual filter group.
    PESDKGroup *customFilterGroup = [[PESDKGroup alloc] initWithIdentifier:@"custom_filter_category" displayName:@"Custom" thumbnail:thumbnail memberIdentifiers:@[@"custom_lut_filter"]];

    // Add the custom filter group to the filter tool.
    [builder configureFilterToolController:^(PESDKFilterToolControllerOptionsBuilder * _Nonnull options) {
      options.filterGroups = [options.filterGroups arrayByAddingObject:customFilterGroup];
    }];
    // highlight-groups
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
