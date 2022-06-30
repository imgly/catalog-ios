import PhotoEditorSDK
import UIKit

// Helper extension for replacing default icons with custom icons.
// highlight-extension
private extension UIImage {
  /// Create a new icon image for a specific size by centering the input image and optionally applying alpha blending.
  /// - Parameters:
  ///   - pt: Icon size in point (pt).
  ///   - alpha: Icon alpha value.
  /// - Returns: A new icon image.
  func icon(pt: CGFloat, alpha: CGFloat = 1) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: pt, height: pt), false, scale)
    let position = CGPoint(x: (pt - size.width) / 2, y: (pt - size.height) / 2)
    draw(at: position, blendMode: .normal, alpha: alpha)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
// highlight-extension

class PhotoCustomizeIconsSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // This example replaces some of the default icons with symbol images provided by SF Symbols.
    // Create a symbol configuration with scale variant large as the default is too small for our use case.
    // highlight-config
    let config = UIImage.SymbolConfiguration(scale: .large)
    // highlight-config

    // Set up the image replacement closure (once) before the editor is initialized.
    // highlight-bundle-image
    IMGLY.bundleImageBlock = { imageName in
      // highlight-bundle-image
      // Print the image names that the SDK is requesting at run time. This allows to interact with the editor and
      // to identify the image names of icons that should be replaced. Alternatively, all default assets can be found
      // in the `ImglyKit.bundle` located within the `ImglyKit.framework`s, e.g., in the directory:
      // `ImglyKit.xcframework/ios-arm64/ImglyKit.framework/ImglyKit.bundle/`
      print(imageName)

      // Return replacement images for the requested image name.
      // Most icon image names use the `pt` postfix which states the expected dimensions for the used image measured
      // in points (pt), e.g., the postfix `_48pt` stands for an image of 48x48 pixels for scale factor 1.0 and 96x96
      // pixels (@2x) as well as 144x144 pixels (@3x) for its high-resolution variants.
      // highlight-switch
      switch imageName {

      // Replace the cancel, approve, and save icons which should have a pre-applied alpha of 0.6 to match the default
      // toolbar appearance.
      case "imgly_icon_cancel_44pt":
        return UIImage(systemName: "multiply.circle.fill", withConfiguration: config)?.icon(pt: 44, alpha: 0.6)
      case "imgly_icon_approve_44pt":
        return UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.icon(pt: 44, alpha: 0.6)
      case "imgly_icon_save":
        return UIImage(systemName: "arrow.down.circle.fill", withConfiguration: config)?.icon(pt: 44, alpha: 0.6)

      // Replace the undo and redo icons.
      case "imgly_icon_undo_48pt":
        return UIImage(systemName: "arrow.uturn.backward", withConfiguration: config)?.icon(pt: 48)
      case "imgly_icon_redo_48pt":
        return UIImage(systemName: "arrow.uturn.forward", withConfiguration: config)?.icon(pt: 48)

      // Returning `nil` will use the default icon image.
      default:
        return nil
      }
      // highlight-switch
    }

    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo)
    photoEditViewController.delegate = self
    photoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
  }

  // MARK: - PhotoEditViewControllerDelegate

  func photoEditViewControllerShouldStart(_ photoEditViewController: PhotoEditViewController, task: PhotoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func photoEditViewControllerDidFinish(_ photoEditViewController: PhotoEditViewController, result: PhotoEditorResult) {
    // The image has been exported successfully and is passed as an `Data` object in the `result.output.data`.
    // To create an `UIImage` from the output, use `UIImage(data:)`.
    // See other examples about how to save the resulting image.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func photoEditViewControllerDidFail(_ photoEditViewController: PhotoEditViewController, error: PhotoEditorError) {
    // There was an error generating the photo.
    print(error.localizedDescription)
    // Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
    // The user tapped on the cancel button within the editor. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
