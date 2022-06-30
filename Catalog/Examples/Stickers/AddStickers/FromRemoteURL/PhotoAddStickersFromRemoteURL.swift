import PhotoEditorSDK
import UIKit

class PhotoAddStickersFromRemoteURLSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a custom sticker.
    // The sticker tool is optimized for remote resources which allows to directly
    // integrate a remote URL instead of downloading the asset before. For an
    // example on how to download the remote resources in advance and use the local
    // downloaded resources, see: Examples/Text/AddFonts/FromRemoteURL.
    // highlight-load-stickers
    let customSticker = Sticker(imageURL: URL(string: "https://img.ly/static/example-assets/custom_sticker_igor.png")!, thumbnailURL: nil, identifier: "custom_sticker_igor")

    // Use an existing sticker from the img.ly bundle.
    let existingSticker = Sticker(imageURL: Bundle.imgly.resourceBundle.url(forResource: "imgly_sticker_emoticons_laugh", withExtension: "png")!, thumbnailURL: nil, identifier: "existing_sticker")
    // highlight-load-stickers

    // Assign the stickers to a new custom sticker category.
    // highlight-categories
    let customStickerCategory = StickerCategory(identifier: "custom_sticker_category", title: "Custom", imageURL: URL(string: "https://img.ly/static/example-assets/custom_sticker_igor.png")!, stickers: [customSticker, existingSticker])
    // highlight-categories

    // Create a `Configuration` object.
    // highlight-configure
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      let assetCatalog = AssetCatalog.defaultItems

      // Add the category to the asset catalog.
      assetCatalog.stickers.append(customStickerCategory)

      // Use the new asset catalog for the configuration.
      builder.assetCatalog = assetCatalog
    }
    // highlight-configure

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
