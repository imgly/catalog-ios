import PhotoEditorSDK
import UIKit

class PhotoStickersConfigurationSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // By default the editor provides a variety of different stickers.
      // For this example the editor should only use the "Shapes" sticker
      // category.
      // highlight-categories
      builder.assetCatalog.stickers = AssetCatalog.defaultItems.stickers.filter { $0.identifier == "imgly_sticker_category_shapes" }
      // highlight-categories

      // Configure the `StickerToolController` which lets the user
      // select the sticker.
      builder.configureStickerToolController { options in
        // By default the user is not allowed to add custom stickers.
        // In this example the user can add stickers from the device.
        // highlight-personalized
        options.personalStickersEnabled = true
        // highlight-personalized

        // By default the preview size of the stickers inside the sticker
        // tool is set to `CGSize(width: 44, height: 44)`.
        // For this example the preview size is set to a bigger size.
        // highlight-preview-size
        options.stickerPreviewSize = CGSize(width: 60, height: 60)
        // highlight-preview-size
      }

      // Configure the `StickerOptionsToolController` which lets the user
      // customize a selected sticker when added to the canvas.
      builder.configureStickerOptionsToolController { options in
        // By default the editor enables all available sticker actions.
        // For this example only a small selection of sticker actions
        // should be allowed.
        // highlight-actions
        options.allowedStickerActions = [.replace, .color]
        // highlight-actions
      }

      // Configure the `StickerColorToolController` which lets the user
      // change the color of the sticker.
      builder.configureStickerColorToolController { options in
        // By default the editor provides a variety of different
        // colors to customize the stickers.
        // For this example only a small selection of colors is enabled
        // per default.
        // highlight-color-tool
        options.availableColors = [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black"),
          Color(color: UIColor.darkGray, colorName: "Dark Gray"),
          Color(color: UIColor.gray, colorName: "Gray")
        ]
        // highlight-color-tool
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
