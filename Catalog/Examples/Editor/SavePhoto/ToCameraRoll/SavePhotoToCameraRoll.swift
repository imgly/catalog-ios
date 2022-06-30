import PhotoEditorSDK
import Photos
import UIKit

class SavePhotoToCameraRollSwift: Example, PhotoEditViewControllerDelegate {
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

    // Request access to save to the user's camera roll.
    // highlight-request-authorization
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
      if status != .authorized {
        // Authorization hasn't been granted. In production you could now for example show an alert asking the user
        // to open their Settings.app to grant permissions. Dismissing the editor.
        print("Authorization to write to the camera roll has not been granted.")
        self?.presentingViewController?.dismiss(animated: true, completion: nil)
        return
      }
      // highlight-request-authorization

      // Perform changes in the shared photo library.
      // highlight-move-photo
      PHPhotoLibrary.shared().performChanges {
        // Create a `PHAssetCreationRequest` and add the image data.
        let assetCreationRequest = PHAssetCreationRequest.forAsset()
        assetCreationRequest.addResource(with: .photo, data: result.output.data, options: nil)
      } completionHandler: { success, error in
        // highlight-move-photo
        // highlight-completion
        if success {
          print("Successfully saved photo to camera roll.")
        } else if let error = error {
          print("Error saving photo to camera roll: \(error)")
        }

        // Dispatching to the main queue and dismissing the editor.
        DispatchQueue.main.async { [weak self] in
          self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
      }
      // highlight-completion
    }
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
