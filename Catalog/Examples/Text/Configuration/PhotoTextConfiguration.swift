import PhotoEditorSDK
import UIKit

class PhotoTextConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TextToolController` which lets the user
      // add text to the image.
      builder.configureTextToolController { options in
        // By default the text alignment is set to `NSTextAlignment.center`.
        // In this example, the default text orientation is set to `NSTextAlignment.left`.
        // highlight-text-align
        options.defaultTextAlignment = .left
        // highlight-text-align

        // By default the editor allows to add emojis as text input.
        // Since emojis are not cross-platform compatible, using the serialization
        // feature to share edits across different platforms will result in emojis
        // being rendered with the system's local set of emojis and therefore will
        // appear differently.
        // For this example emoji input is disabled to ensure a consistent cross-platform experience.
        // highlight-emojis
        options.emojisEnabled = false
        // highlight-emojis

        // By default the minimum text size is set to 20pt.
        // For this example the minimum size is reduced.
        // highlight-size
        options.minimumTextSize = 17.0
        // highlight-size
      }

      // Configure the `TextFontToolController` which lets the user
      // change the font of the text.
      builder.configureTextFontToolController { options in
        // This closure is executed every time the user selects a font.
        // highlight-font-selection
        options.textFontActionSelectedClosure = { fontName in
          print("Font has been selected with name:", fontName)
        }
        // highlight-font-selection
      }

      // Configure the `TextColorToolController` which lets the user
      // change the color of the text.
      builder.configureTextColorToolController { options in
        // By default the editor provides a variety of different
        // colors to customize the color of the text.
        // For this example only a small selection of colors is shown by default
        // e.g. based on favorite colors of the user.
        // highlight-colors
        options.availableColors = [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black")
        ]
        // highlight-colors

        // By default the editor provides a variety of different
        // colors to customize the background color of the text.
        // For this example only a small selection of colors is shown by default
        // e.g. based on favorite colors of the user.
        // highlight-background-colors
        options.availableBackgroundTextColors = [
          Color(color: UIColor.red, colorName: "Red"),
          Color(color: UIColor.green, colorName: "Green"),
          Color(color: UIColor.yellow, colorName: "Yellow")
        ]
        // highlight-background-colors
      }
    }

    // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
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
