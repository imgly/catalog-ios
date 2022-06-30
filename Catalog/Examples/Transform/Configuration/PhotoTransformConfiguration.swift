import PhotoEditorSDK
import UIKit

class PhotoTransformConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TransformToolController` that lets the user
      // crop and rotate the image.
      builder.configureTransformToolController { options in
        // By default the editor has a lot of crop aspects enabled.
        // For this example only a couple are enabled, e.g. if you
        // only allow certain image aspects in your application.
        // highlight-crop-ratios
        options.allowedCropRatios = [
          CropAspect(width: 1, height: 1),
          CropAspect(width: 16, height: 9, localizedName: "Landscape")
        ]
        // highlight-crop-ratios

        // By default the editor allows to use a free crop ratio.
        // For this example this is disabled to ensure that the image
        // has a suitable ratio.
        // highlight-free-crop
        options.allowFreeCrop = false
        // highlight-free-crop

        // By default the editor shows the reset button which resets
        // the applied transform operations. In this example the button
        // is hidden since we are enforcing certain ratios and the user
        // can only select among them anyway.
        // highlight-reset-button
        options.showResetButton = false
        // highlight-reset-button
      }

      // Configure the `PhotoEditViewController`.
      builder.configurePhotoEditViewController { options in
        // For this example the user is forced to crop the asset to one of
        // the allowed crop aspects specified above, before being able to use other
        // features of the editor. The transform tool will only be presented
        // if the image does not already fit one of those allowed aspect ratios.
        // highlight-force-crop
        options.forceCropMode = true
        // highlight-force-crop
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
