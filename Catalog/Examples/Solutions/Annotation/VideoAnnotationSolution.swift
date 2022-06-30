import UIKit
import VideoEditorSDK

class VideoAnnotationSolutionSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

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

      // Configure the `VideoEditViewController`.
      builder.configureVideoEditViewController { options in
        // Assign the custom selection of tools.
        options.menuItems = menuItems
      }
    }
    // highlight-config

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
