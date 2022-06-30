import AVFoundation
import PhotoEditorSDK
import UIKit
import UniformTypeIdentifiers

class OpenPhotoFromCameraRollSwift: Example, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // We recommend using the old `UIImagePickerController` class instead of the newer `PHPickerViewController`
    // due to video import issues for some MP4 files encoded with non-ffmpeg codecs. We've filed a bug report
    // with Apple regarding this issue. If you do not require support for video files, feel free to use
    // `PHPickerViewController`.
    // highlight-instantiate-picker
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    imagePicker.mediaTypes = [UTType.image.identifier]
    // highlight-instantiate-picker

    // Present the image picker modally.
    imagePicker.modalPresentationStyle = .fullScreen
    presentingViewController?.present(imagePicker, animated: true, completion: nil)
  }

  // MARK: - UIImagePickerControllerDelegate

  // highlight-imagepicker-delegate
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    guard let image = info[.originalImage] as? UIImage else {
      fatalError()
    }

    // Dismiss the image picker and present the photo editor after dismissal is done.
    presentingViewController?.dismiss(animated: true, completion: {
      // Create a `Photo` from the picked photo.
      let photo = Photo(image: image)

      // Create a photo editor and pass it the photo. Make this class the delegate of it to handle export and cancelation.
      let photoEditViewController = PhotoEditViewController(photoAsset: photo)
      photoEditViewController.delegate = self

      // Present the photo editor.
      photoEditViewController.modalPresentationStyle = .fullScreen
      self.presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
    })
  }
  // highlight-imagepicker-delegate

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    presentingViewController?.dismiss(animated: true, completion: nil)
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
