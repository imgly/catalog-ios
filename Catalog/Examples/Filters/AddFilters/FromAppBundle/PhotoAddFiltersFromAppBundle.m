#import "PhotoAddFiltersFromAppBundle.h"
@import PhotoEditorSDK;

@interface PhotoAddFiltersFromAppBundleObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoAddFiltersFromAppBundleObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

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

  // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
  PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:photo configuration:configuration];
  photoEditViewController.delegate = self;
  photoEditViewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self.presentingViewController presentViewController:photoEditViewController animated:YES completion:nil];
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
