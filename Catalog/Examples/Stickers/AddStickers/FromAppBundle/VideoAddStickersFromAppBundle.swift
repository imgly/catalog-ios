import UIKit
import VideoEditorSDK

class VideoAddStickersFromAppBundleSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a custom sticker.
    // highlight-load-stickers
    let customSticker = Sticker(imageURL: Bundle.main.url(forResource: "custom_sticker_igor", withExtension: "png")!, thumbnailURL: nil, identifier: "custom_sticker_igor")

    // Use an existing sticker from the img.ly bundle.
    let existingSticker = Sticker(imageURL: Bundle.imgly.resourceBundle.url(forResource: "imgly_sticker_emoticons_laugh", withExtension: "png")!, thumbnailURL: nil, identifier: "existing_sticker")
    // highlight-load-stickers

    // Assign the stickers to a new custom sticker category.
    // highlight-categories
    let customStickerCategory = StickerCategory(identifier: "custom_sticker_category", title: "Custom", imageURL: Bundle.main.url(forResource: "custom_sticker_igor", withExtension: "png")!, stickers: [customSticker, existingSticker])
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
