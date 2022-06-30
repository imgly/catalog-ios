import PhotoEditorSDK
import UIKit

class PhotoFramesConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `FrameToolController` which lets the user
      // select a frame.
      builder.configureFrameToolController { options in
        // By default the editor does not allow to rotate the image in
        // the frame tool by using the roation gestures. For this example,
        // this behavior is enabled.
        options.rotationEnabled = true
      }

      // Configure the `FrameOptionsToolController` which allows customization
      // of the selected frame.
      builder.configureFrameOptionsToolController { options in
        // By default the editor enables all available frame actions.
        // For this example only a small selection is enabled.
        options.allowedFrameActions = [.replace, .opacity]
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
