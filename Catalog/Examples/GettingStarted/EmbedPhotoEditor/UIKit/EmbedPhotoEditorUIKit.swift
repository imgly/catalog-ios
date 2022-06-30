import PhotoEditorSDK
import UIKit

class EmbedPhotoEditorUIKitSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create the photo editor. Make this class the delegate of it to handle export and cancelation.
    // highlight-create-editor
    let photoEditViewController = PhotoEditViewController(photoAsset: photo)
    photoEditViewController.delegate = self
    // highlight-create-editor

    // Create and present a navigation controller that hosts the photo editor.
    // The photo editor will now use the navigation controller's navigation bar for its cancel and save
    // buttons instead of its own toolbar.
    // If the photo editor is the navigation controller's root view controller, it will display the close
    // button on the left side of the navigation bar and call `photoEditViewControllerDidCancel(_:)` when
    // the user taps on it.
    // If the photo editor is *not* the navigation controller's root view controller, it will display the
    // regular back button on the left side of the navigation bar and will *not* call
    // `photoEditViewControllerDidCancel(_:)` when tapping on it.
    // highlight-embed
    let navigationController = UINavigationController(rootViewController: photoEditViewController)
    navigationController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(navigationController, animated: true, completion: nil)
    // highlight-embed
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
