import UIKit
import VideoEditorSDK

class VideoStickersConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

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
        options.allowedStickerActions = [.duration, .replace, .color]
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

    // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
    let videoEditViewController = VideoEditViewController(videoAsset: video, configuration: configuration)
    videoEditViewController.delegate = self
    videoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
  }

  // MARK: - VideoEditViewControllerDelegate

  func videoEditViewControllerShouldStart(_ videoEditViewController: VideoEditViewController, task: VideoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func videoEditViewControllerDidFinish(_ videoEditViewController: VideoEditViewController, result: VideoEditorResult) {
    // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func videoEditViewControllerDidFail(_ videoEditViewController: VideoEditViewController, error: VideoEditorError) {
    // There was an error generating the video.
    print(error.localizedDescription)
    // Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func videoEditViewControllerDidCancel(_ videoEditViewController: VideoEditViewController) {
    // The user tapped on the cancel button within the editor. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
