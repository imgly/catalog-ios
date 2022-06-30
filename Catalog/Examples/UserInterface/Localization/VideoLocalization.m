#import "VideoLocalization.h"
@import VideoEditorSDK;

@interface VideoLocalizationObjC () <PESDKVideoEditViewControllerDelegate>

@end

@implementation VideoLocalizationObjC

- (void)invokeExample {
  // Create a `PESDKVideo` from a URL to an image in the app bundle.
  PESDKVideo *video = [[PESDKVideo alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"Skater" withExtension:@"mp4"]];

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
  [VESDK setLocalizationDictionary: @{
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
  [VESDK setLocalizationBlock:^NSString * _Nullable(NSString * _Nonnull stringToLocalize) {
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
