#import "PhotoCustomizeIcons.h"
@import PhotoEditorSDK;

// Helper category for replacing default icons with custom icons.
@implementation UIImage (PhotoCustomizeIconsObjC)

/// Create a new icon image for a specific size by centering the input image.
/// @param pt Icon size in point (pt).
// highlight-extension
- (nonnull UIImage *)pesdk_iconWithPt:(CGFloat)pt {
  return [self pesdk_iconWithPt:pt alpha:1];
}

/// Create a new icon image for a specific size by centering the input image and applying alpha blending.
/// @param pt Icon size in point (pt).
/// @param alpha Icon alpha value.
- (nonnull UIImage *)pesdk_iconWithPt:(CGFloat)pt alpha:(CGFloat)alpha {
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(pt, pt), NO, self.scale);
  CGPoint position = CGPointMake((pt - self.size.width) / 2, (pt - self.size.height) / 2);
  [self drawAtPoint:position blendMode:kCGBlendModeNormal alpha:alpha];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}
// highlight-extension

@end

@interface PhotoCustomizeIconsObjC () <PESDKPhotoEditViewControllerDelegate>

@end

@implementation PhotoCustomizeIconsObjC

- (void)invokeExample {
  // This example replaces some of the default icons with symbol images provided by SF Symbols.
  // Create a symbol configuration with scale variant large as the default is too small for our use case.
  // highlight-config
  UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleLarge];
  // highlight-config

  // Set up the image replacement closure (once) before the editor is initialized.
  // highlight-bundle-image
  [IMGLY setBundleImageBlock:^UIImage * _Nullable(NSString * _Nonnull imageName) {
  // highlight-bundle-image
    // Print the image names that the SDK is requesting at run time. This allows to interact with the editor and
    // to identify the image names of icons that should be replaced. Alternatively, all default assets can be found
    // in the `ImglyKit.bundle` located within the `ImglyKit.framework`s, e.g., in the directory:
    // `ImglyKit.xcframework/ios-arm64/ImglyKit.framework/ImglyKit.bundle/`
    NSLog(@"%@", imageName);

    // Return replacement images for the requested image name.
    // Most icon image names use the `pt` postfix which states the expected dimensions for the used image measured
    // in points (pt), e.g., the postfix `_48pt` stands for an image of 48x48 pixels for scale factor 1.0 and 96x96
    // pixels (@2x) as well as 144x144 pixels (@3x) for its high-resolution variants.

    // Replace the cancel, approve, and save icons which should have a pre-applied alpha of 0.6 to match the default
    // toolbar appearance.
    // highlight-switch
    if ([imageName isEqualToString:@"imgly_icon_cancel_44pt"]) {
      return [[UIImage systemImageNamed:@"multiply.circle.fill" withConfiguration:config] pesdk_iconWithPt:44 alpha:0.6];
    } else if ([imageName isEqualToString:@"imgly_icon_approve_44pt"]) {
      return [[UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:config] pesdk_iconWithPt:44 alpha:0.6];
    } else if ([imageName isEqualToString:@"imgly_icon_save"]) {
      return [[UIImage systemImageNamed:@"arrow.down.circle.fill" withConfiguration:config] pesdk_iconWithPt:44 alpha:0.6];
    }

    // Replace the undo and redo icons.
    else if ([imageName isEqualToString:@"imgly_icon_undo_48pt"]) {
      return [[UIImage systemImageNamed:@"arrow.uturn.backward" withConfiguration:config] pesdk_iconWithPt:48];
    } else if ([imageName isEqualToString:@"imgly_icon_redo_48pt"]) {
      return [[UIImage systemImageNamed:@"arrow.uturn.forward" withConfiguration:config] pesdk_iconWithPt:48];
    }

    // Returning `nil` will use the default icon image.
    return nil;
    // highlight-switch
  }];

  // Create a `PESDKPhoto` from a URL to an image in the app bundle.
  PESDKPhoto *photo = [[PESDKPhoto alloc] initWithURL:[NSBundle.mainBundle URLForResource:@"LA" withExtension:@"jpg"]];

  // Create a default `PESDKConfiguration`.
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
