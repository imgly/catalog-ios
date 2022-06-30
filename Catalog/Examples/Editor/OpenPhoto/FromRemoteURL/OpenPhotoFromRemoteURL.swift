import PhotoEditorSDK
import UIKit

class OpenPhotoFromRemoteURLSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Although the editor supports opening a remote URL, we highly recommend
    // that you manage the download of the remote resource yourself, since this
    // gives you more control over the whole process. After successfully downloading
    // the file you should pass a `Data` object or a local URL to the downloaded photo
    // to the editor. This example demonstrates how to achieve the former.
    guard let remoteURL = URL(string: "https://img.ly/static/example-assets/LA.jpg") else {
      fatalError("Unable to parse URL.")
    }

    // highlight-download
    let downloadTask = URLSession.shared.downloadTask(with: remoteURL) { downloadURL, _, error in
      if let error = error {
        fatalError("There was an error downloading the file: \(error)")
      }

      if let downloadURL = downloadURL {
        // File was downloaded successfully. Creating a `Data` object from it.
        // To save memory you can also save the file to disk instead of keeping it in memory.
        // For an example on how to do this, see `OpenVideoFromRemoteURLSwift`.
        let imageData = try? Data(contentsOf: downloadURL)
        // highlight-download

        // Dispatch to the main queue for any UI work.
        // highlight-instantiation
        DispatchQueue.main.async {
          // Create a `Photo` from the `Data` object.
          let photo = Photo(data: imageData!)

          // Create a photo editor and pass it the photo. Make this class the delegate of it to handle export and cancelation.
          let photoEditViewController = PhotoEditViewController(photoAsset: photo)
          photoEditViewController.delegate = self
          // highlight-instantiation

          // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
          // highlight-user-interaction
          self.presentingViewController?.view.isUserInteractionEnabled = true

          // Present the photo editor.
          photoEditViewController.modalPresentationStyle = .fullScreen
          self.presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
        }
      }
    }

    // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
    presentingViewController?.view.isUserInteractionEnabled = false
    // highlight-user-interaction

    // Start the file download
    downloadTask.resume()
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
