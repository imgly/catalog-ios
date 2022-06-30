import PhotoEditorSDK
import UIKit

class PhotoTextDesignConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TextDesignToolController` that lets the user
      // add text designs to the image.
      builder.configureTextDesignToolController { options in
        // By default the editor allows to add emojis as text input.
        // Since emojis are not cross-platform compatible, using the serialization
        // feature to share edits across different platforms will result in emojis
        // being rendered with the system's local set of emojis and therefore will
        // appear differently.
        // For this example emoji input is disabled to ensure a consistent cross-platform experience.
        // highlight-emojis
        options.emojisEnabled = false
        // highlight-emojis

        // By default the editor provides a `ColorPalette` with a lot of colors.
        // For this example this will be replaced with a `ColorPalette`
        // with only a few colors enabled.
        // highlight-color
        options.colorPalette = ColorPalette(colors: [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black")
        ])
        // highlight-color
      }

      // Configure the `TextDesignOptionsToolController` that lets the user
      // change text designs that have been placed on top of the image.
      // highlight-actions
      builder.configureTextDesignOptionsToolController { options in
        // By default the editor has all available overlay actions for this tool
        // enabled. For this example `TextDesignOverlayAction.undo` and `TextDesignOverlayAction.redo`
        // are removed.
        options.allowedTextDesignOverlayActions = [.add, .bringToFront, .delete, .invert]
      }
      // highlight-actions
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
