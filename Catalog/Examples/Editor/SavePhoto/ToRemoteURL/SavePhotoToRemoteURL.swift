import PhotoEditorSDK
import UIKit

class SavePhotoToRemoteURLSwift: Example, PhotoEditViewControllerDelegate {
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

  // highlight-photo-export-delegate
  func photoEditViewControllerDidFinish(_ photoEditViewController: PhotoEditViewController, result: PhotoEditorResult) {
    // highlight-photo-export-delegate
    // After the output image is done processing, this delegate method will be called.
    //
    // The `result.output.data` attribute will contain the output image data, including all EXIF information in the format specified in your editor's configuration.
    //
    // If *no modifications* have been made to the image and the `Photo` object that was passed to the editor's initializer
    // was created using `Photo(data:)` or `Photo(url:)` we will not process the image at all and simply forward it to this delegate method.
    // If the `Photo` object that was passed to the editor's initializer was created using `Photo(image:)`, it will be processed and returned
    // in the format specified in your editor's configuration.
    //
    // You can set `PhotoEditViewControllerOptions.forceExport` to `true` in which case the image will be passed through our
    // rendering pipeline in any case, even without any modifications applied.

    // Create a `URLRequest` object for the web service that will receive this upload. This example doesn't use a valid
    // URL and the request will fail.
    // highlight-create-request
    var urlRequest = URLRequest(url: URL(string: "http://localhost/fileupload")!)
    // Most web services will expect the 'POST' HTTP method for file uploads.
    urlRequest.httpMethod = "POST"
    // highlight-create-request

    // Create the upload task.
    // highlight-upload
    let uploadTask = URLSession.shared.uploadTask(with: urlRequest, from: result.output.data) { data, response, error in
      if let error = error {
        print("The file upload failed: \(error)")
      }

      if let response = response as? HTTPURLResponse {
        print("The server replied with status code \(response.statusCode)")
      }

      if let data = data {
        print("Received a \(data.count) byte answer from the server.")
      }
    }
    // highlight-upload

    // Start the upload task. This will run in the background, so the view controller can be dismissed immediately.
    // highlight-background
    uploadTask.resume()
    // highlight-background
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
