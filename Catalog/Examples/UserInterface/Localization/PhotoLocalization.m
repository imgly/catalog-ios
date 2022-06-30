#import "PhotoLocalization.h"
@import PhotoEditorSDK;

@interface PhotoLocalizationObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoLocalizationObjC

- (void)invokeExample {
  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // The default option to localize the editor is to use a `Localizable.strings`
  // file containing the localization keys and the corresponding localized
  // strings as values.
  // For further reference, please take a look at the official guides by
  // Apple: https://developer.apple.com/documentation/Xcode/localization

  // Another way to localize the editor is to provide a custom localization
  // dictionary. The key of the dictionary needs to be the locale that
  // you want to add or change, the value should be another dictionary
  // containing the localization keys and the corresponding localized
  // strings as values.
  // For this example, the editor overrides some values for the provided
  // English localization.
  // highlight-dictionary
  [PESDK setLocalizationDictionary: @{
    @"en": @{
      @"pesdk_transform_title_name": @"Crop",
      @"pesdk_adjustments_title_name": @"Correct",
      @"pesdk_adjustments_button_reset": @"Clear"
    }
  }];
  // highlight-dictionary

  // The more advanced way to add localization is passing a closure,
  // which will be called for each string that can be localized.
  // You can then use that closure to look up a matching localization
  // in your app's `Localizable.strings` file or do something completely custom.
  //
  // Please note that if the `localizationBlock` and the `localizationDictionary`
  // both include a localization value for the same string, the value of the
  // `localizationBlock` takes precedence.
  // highlight-closure
  [PESDK setLocalizationBlock:^NSString * _Nullable(NSString * _Nonnull stringToLocalize) {
    if ([stringToLocalize  isEqual: @"pesdk_brush_title_name"]) {
      return @"Draw";
    } else if ([stringToLocalize  isEqual: @"pesdk_filter_title_name"]) {
      return @"Effects";
    } else if ([stringToLocalize  isEqual: @"pesdk_textDesign_title_name"]) {
      return @"Designs";
    } else {
      return nil;
    }
  }];
  // highlight-closure

  // Create a default `PESDKConfiguration` object.
  PESDKConfiguration *configuration = [[PESDKConfiguration alloc] init];

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
