import PhotoEditorSDK
import UIKit

class PhotoLocalizationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

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
    PESDK.localizationDictionary = [
      "en": [
        "pesdk_transform_title_name": "Crop",
        "pesdk_adjustments_title_name": "Correct",
        "pesdk_adjustments_button_reset": "Clear"
      ]
    ]
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
    PESDK.localizationBlock = { stringToLocalize in
      switch stringToLocalize {
      case "pesdk_brush_title_name":
        return "Draw"
      case "pesdk_filter_title_name":
        return "Effects"
      case "pesdk_textDesign_title_name":
        return "Designs"
      default:
        return nil
      }
    }
    // highlight-closure

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
