import PhotoEditorSDK
import UIKit

class PhotoAnnotationSolutionSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // For this example only the sticker, text, and brush tool are enabled.
    // highlight-menu
    let toolItems = [ToolMenuItem.createStickerToolItem(), ToolMenuItem.createTextToolItem(), ToolMenuItem.createBrushToolItem()]
    let menuItems: [PhotoEditMenuItem] = toolItems.compactMap { menuItem in
      if let menuItem = menuItem {
        return .tool(menuItem)
      }
      return nil
    }
    // highlight-menu

    // For this example only stickers suitable for annotations are enabled.
    // highlight-stickers
    let stickerIdentifiers = ["imgly_sticker_shapes_arrow_02", "imgly_sticker_shapes_arrow_03", "imgly_sticker_shapes_badge_11", "imgly_sticker_shapes_badge_12", "imgly_sticker_shapes_badge_36"]
    let stickers = stickerIdentifiers.map { Sticker(imageURL: Bundle.imgly.resourceBundle.url(forResource: $0, withExtension: "png")!, thumbnailURL: nil, identifier: $0) }

    // Create a custom sticker category for the annotation stickers.
    let stickerCategory = StickerCategory(identifier: "annotation_stickers", title: "Annotation", imageURL: Bundle.imgly.resourceBundle.url(forResource: "imgly_sticker_shapes_arrow_02", withExtension: "png")!, stickers: stickers)
    // highlight-stickers

    // Create a `Configuration` object.
    // highlight-config
    let configuration = Configuration { builder in
      // Add the annotation sticker category to the asset catalog.
      builder.assetCatalog.stickers = [stickerCategory]

      // Configure the `PhotoEditViewController`.
      builder.configurePhotoEditViewController { options in
        // Assign the custom selection of tools.
        options.menuItems = menuItems
      }
    }
    // highlight-config

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
