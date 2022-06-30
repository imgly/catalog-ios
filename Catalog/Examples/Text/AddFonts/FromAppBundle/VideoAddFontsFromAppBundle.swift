import UIKit
import VideoEditorSDK

class VideoAddFontsFromAppBundleSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a reference to a custom font.
    // highlight-objects
    let fontURL = Bundle.main.url(forResource: "custom_font_raleway_regular", withExtension: "ttf")
    let customFont = Font(url: fontURL!, displayName: "Raleway", fontName: "custom_font_raleway_regular", identifier: "custom_font_raleway_regular")

    // Create a reference to a system font.
    let systemFont = Font(displayName: "Helvetica", fontName: "Helvetica", identifier: "system_font_helvetica")
    // highlight-objects

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      // highlight-catalog
      let assetCatalog = AssetCatalog.defaultItems

      // Add the custom fonts to the asset catalog.
      assetCatalog.fonts.append(contentsOf: [customFont, systemFont])

      // Use the new asset catalog for the configuration.
      builder.assetCatalog = assetCatalog
      // highlight-catalog
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
