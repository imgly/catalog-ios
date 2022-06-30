import MobileCoreServices
import PhotoEditorSDK
import UIKit
import UniformTypeIdentifiers

class SavePhotoToFilesystemSwift: Example, PhotoEditViewControllerDelegate {
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

    // highlight-save-photo
    guard let uti = result.output.uti, let type = UTType(uti as String) else { return }

    // Get a reference to the temporary directory and append the filename and extension.
    let temporaryDirectoryURL = FileManager.default.temporaryDirectory
    // Append a random filename with an extension matching the output format's UTI.
    let localURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString, conformingTo: type)

    if FileManager.default.fileExists(atPath: localURL.path) {
      // Remove the file at the destination if it already exists.
      try? FileManager.default.removeItem(at: localURL)
    }

    // Write image data to `localURL`.
    try? result.output.data.write(to: localURL)
    // highlight-save-photo

    // You can now use `localURL` for further processing. Dismissing the editor now.
    print("Saved image at \(localURL)")
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
