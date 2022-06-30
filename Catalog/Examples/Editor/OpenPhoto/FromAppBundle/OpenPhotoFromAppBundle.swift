import PhotoEditorSDK
import UIKit

class OpenPhotoFromAppBundleSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Get the URL for a file on the local file system. This could be any file within the app bundle
    // or also a file within the documents or temporary folders for example. This example will use
    // a file from the app bundle.
    // highlight-bundle-url
    guard let url = Bundle.main.url(forResource: "LA", withExtension: "jpg") else {
      fatalError("Unable to create URL for specified file.")
    }
    // highlight-bundle-url

    // Create a `Photo` from the photo URL.
    // highlight-instantiation
    let photo = Photo(url: url)

    // Create a photo editor and pass it the photo. Make this class the delegate of it to handle export and cancelation.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo)
    photoEditViewController.delegate = self
    // highlight-instantiation

    // Present the photo editor.
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
