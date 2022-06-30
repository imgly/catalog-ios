import PhotoEditorSDK
import UIKit

class ShowPhotoCameraUIKitSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Configuration` object.
    // highlight-configuration
    let configuration = Configuration { builder in
      builder.configureCameraViewController { options in
        // By default the camera view controller does not show a cancel button,
        // so that it can be embedded into any other view controller. But since it is
        // presented modally here, a cancel button should be visible.
        options.showCancelButton = true

        // Enable photo only.
        options.allowedRecordingModes = [.photo]
      }
    }

    // Create the camera view controller passing above configuration.
    let cameraViewController = CameraViewController(configuration: configuration)
    // highlight-configuration

    // The `cancelBlock` will be called when the user taps the cancel button.
    // highlight-cancel-block
    cameraViewController.cancelBlock = { [weak self] in
      // Dismiss the camera view controller.
      self?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    // highlight-cancel-block

    // The `completionBlock` will be called once a photo has been taken or when the user selects a photo from the camera roll.
    // The `Data` argument will contain the photo in JPEG format with all EXIF information.
    // highlight-completion-block
    cameraViewController.completionBlock = { [weak self] result in
      // Create a `Photo` from the `Data` object.
      guard let data = result.data else { return }
      let photo = Photo(data: data)
      // Dismiss the camera view controller and open the photo editor after dismissal.
      self?.presentingViewController?.dismiss(animated: true, completion: {
        // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
        // Passing the `result.model` to the editor to preserve selected filters.
        let photoEditViewController = PhotoEditViewController(photoAsset: photo, photoEditModel: result.model)
        photoEditViewController.delegate = self
        photoEditViewController.modalPresentationStyle = .fullScreen
        self?.presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
      })
    }
    // highlight-completion-block

    // Present the camera view controller.
    // To take photos, the camera will require the `NSCameraUsageDescription` key to be present in your Info.plist file.
    // To access photos in the camera roll, the camera will require the `NSPhotoLibraryUsageDescription` key to be present in your Info.plist file.
    // To record videos, the camera will require the `NSMicrophoneUsageDescription` key to be present in your Info.plist file.
    // highlight-present
    cameraViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(cameraViewController, animated: true, completion: nil)
    // highlight-present
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
