import PhotoEditorSDK
import UIKit

class PhotoEditorConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to a photo in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      builder.configurePhotoEditViewController { options in
        // By default the editor allows to zoom the image in the preview.
        // For this example, this behavior is disabled.
        options.allowsPreviewImageZoom = false

        // By default the editor uses a compression quality of 90% (0.9)
        // for lossy export formats.
        // For this example the compression quality is set to 25% (0.25)
        // e.g. for when the exported image is only used as a thumbnail.
        options.compressionQuality = 0.25

        // By default the editor has insets of 12 pt for each side - except for top
        // since this value is ignored.
        // For this example the insets are set to increase the spacing.
        options.overlayButtonInsets = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)

        // By default the editor exports the image in JPG format.
        // For this example the editor should export the image as HEIF
        // to improve compression efficiency.
        options.outputImageFileFormat = .heif
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
