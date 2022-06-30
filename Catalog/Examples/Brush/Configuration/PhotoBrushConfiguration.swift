import PhotoEditorSDK
import UIKit

class PhotoBrushConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `BrushToolController` which lets the user
      // draw on the image.
      builder.configureBrushToolController { options in
        // By default all available brush tools are enabled.
        // For this example only a couple are enabled.
        // highlight-tools
        options.allowedBrushTools = [.color, .size]
        // highlight-tools

        // By default the default color for the brush stroke is
        // `UIColor.white`. For this example the default color
        // is set to `UIColor.black`.
        // highlight-color
        options.defaultBrushColor = UIColor.black
        // highlight-color

        // By default the default brush size is set to 5% of the
        // smaller side of the image.
        // For this example the default size should be absolute.
        // highlight-size
        options.defaultBrushSize = FloatValue.absolute(5.0)
        // highlight-size
      }

      // Configure the `BrushColorToolController` which lets the user
      // change the color of the brush stroke.
      builder.configureBrushColorToolController { options in
        // By default the editor provides a variety of different
        // colors to customize the color of the brush stroke.
        // For this example only a small selection of colors is enabled.
        // highlight-colors
        options.availableColors = [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black"),
          Color(color: UIColor.red, colorName: "Red")
        ]
        // highlight-colors
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
