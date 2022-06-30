import UIKit
import VideoEditorSDK

class VideoAddOverlaysFromRemoteURLSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a custom `Overlay`.
    // The overlay tool is optimized for remote resources which allows to directly
    // integrate a remote URL instead of downloading the asset before. For an
    // example on how to download the remote resources in advance and use the local
    // downloaded resources, see: Examples/Text/AddFonts/FromRemoteURL.
    // highlight-custom-overlays
    let customOverlay = Overlay(identifier: "imgly_overlay_grain", displayName: "Grain", url: URL(string: "https://img.ly/static/example-assets/imgly_overlay_grain.jpg")!, thumbnailURL: nil, initialBlendMode: .hardLight)
    // highlight-custom-overlays

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      // highlight-catalog
      let assetCatalog = AssetCatalog.defaultItems

      // Add the custom overlay to the asset catalog.
      assetCatalog.overlays.append(customOverlay)

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
