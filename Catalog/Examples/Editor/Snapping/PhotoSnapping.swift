import PhotoEditorSDK
import UIKit

class PhotoSnapping: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the snapping of all sprites globally in the editor.
      //
      // For this example the editor's snapping behavior is configured
      // to act as a guide for the user to see where the sprites should
      // be placed. A use case could be that an application displays
      // profile pictures both in rectangular as well as in circular
      // shapes which requires the editor to indicate where the area
      // is in which sprites' visibility is best.
      builder.configureSnapping { options in
        // By default the snapping is enabled when rotating a sprite.
        // For this example this behavior is disabled since only the
        // outer positional snapping guides are needed.
        // highlight-rotation
        options.rotationSnappingEnabled = false
        // highlight-rotation

        // By default the center of the sprite snaps to a vertical
        // line indicating the center of the image.
        // For this example this behavior is disabled since only the
        // outer positional snapping guides are needed.
        // highlight-vertical-line
        options.snapToVerticalCenterLine = false
        // highlight-vertical-line

        // By default the center of the sprite snaps to a horizontal
        // line indicating the center of the image.
        // For this example this behavior is disabled since only the
        // outer positional snapping guides are needed.
        // highlight-horizontal-line
        options.snapToHorizontalCenterLine = false
        // highlight-horizontal-line

        // By default the sprite snaps to a horizontal line
        // on the bottom of the image. This value is measured in normalized
        // coordinates relative to the smaller side of the edited image and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the image.
        // highlight-positional
        options.snapToBottom = 0.15

        // By default the sprite snaps to a horizontal line
        // on the top of the image. This value is measured in normalized
        // coordinates relative to the smaller side of the edited image and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the image.
        options.snapToTop = 0.15

        // By default the sprite snaps to a vertical line
        // on the left of the image. This value is measured in normalized
        // coordinates relative to the smaller side of the edited image and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the image.
        options.snapToLeft = 0.15

        // By default the sprite snaps to a vertical line
        // on the right of the image. This value is measured in normalized
        // coordinates relative to the smaller side of the edited image and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the image.
        options.snapToRight = 0.15
        // highlight-positional
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
