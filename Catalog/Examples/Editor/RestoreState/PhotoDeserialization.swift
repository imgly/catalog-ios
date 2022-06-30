import PhotoEditorSDK
import UIKit

class PhotoDeserializationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a default `Configuration` with default `AssetCatalog`.
    let configuration = Configuration { builder in
      builder.assetCatalog = AssetCatalog.defaultItems
    }

    // Load the serialized settings from the app bundle. You could also load this from a remote URL for example.
    // See `OpenPhotoFromRemoteURLSwift` to get an idea about the approach to take for this.
    // highlight-load-settings
    let serializedSettings = try? Data(contentsOf: Bundle.main.url(forResource: "photo_serialization", withExtension: "json")!)
    // highlight-load-settings

    // Deserialize the serialized settings. If the photo was not serialized along with the edits or you're not sure
    // that the aspect ratio of the current photo and the photo used when creating the serialized settings are identical,
    // you should specify the size of the photo to apply the edits on.
    // highlight-deserialize
    let deserializationResult = Deserializer.deserialize(data: serializedSettings!, imageDimensions: photo.size, assetCatalog: configuration.assetCatalog)

    // Get the `PhotoEditModel` from the deserialization result.
    let photoEditModel = deserializationResult.model!

    // If the original photo was serialized along with the edits, you could receive it from the deserialization
    // result like this.
    // let photo = Photo.from(photoRepresentation: deserializationResult.photo!)

    // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
    // Pass the deserialized `PhotoEditModel` to the editor.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration, photoEditModel: photoEditModel)
    // highlight-deserialize
    photoEditViewController.delegate = self
    photoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(photoEditViewController, animated: true, completion: nil)

    // For saving edits, please take a look at `PhotoSerializationSwift`.
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
