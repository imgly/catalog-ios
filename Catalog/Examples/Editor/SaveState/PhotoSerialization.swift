import PhotoEditorSDK
import UIKit

class PhotoSerializationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    // highlight-setup
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo)
    photoEditViewController.delegate = self
    photoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
    // highlight-setup
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

    // To get a `Data` object of all edits which have been applied to an image, you can use the following method.
    // You can decide whether the serialized settings should also contain the JPEG-encoded image data or not.
    // highlight-serialization
    let serializedSettings = photoEditViewController.serializedSettings(withImageData: false)

    // Optionally, you can convert the serialized settings to a JSON string if needed.
    let jsonString = String(data: serializedSettings!, encoding: .utf8)
    print(jsonString!)

    // Or to a `Dictionary`.
    let jsonDict = try? JSONSerialization.jsonObject(with: serializedSettings!, options: [])
    print(jsonDict! as Any)
    // highlight-serialization

    // You can use either `serializedSettings`, `jsonString`, or `jsonDict` for further processing, such as
    // uploading it to a remote URL or saving it to the filesystem. See `SavePhotoToRemoteURLSwift` or
    // `SavePhotoToFilesystemSwift` to get an idea about the approach to take for this.

    // For loading serialized settings into the editor, please take a look at `PhotoDeserializationSwift`.

    // Dismiss the editor.
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
