import UIKit
import VideoEditorSDK

class AddAudioOverlaysFromAppBundleSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Identifiers of audio clips in the app bundle.
    // highlight-load-clips
    let elsewhereAudioClipIdentifiers = [
      "elsewhere",
      "trapped_in_the_upside_down"
    ]
    let otherAudioClipIdentifiers = [
      "dance_harder",
      "far_from_home"
    ]

    // Create new audio clip categories with custom audio clips from
    // the app bundle.
    let elsewhereClips = elsewhereAudioClipIdentifiers.map { AudioClip(identifier: $0, audioURL: Bundle.main.url(forResource: $0, withExtension: ".mp3")!) }
    let otherClips = otherAudioClipIdentifiers.map { AudioClip(identifier: $0, audioURL: Bundle.main.url(forResource: $0, withExtension: ".mp3")!) }
    // highlight-load-clips

    // highlight-categories
    let elsewhereAudioClipCategory = AudioClipCategory(title: "Elsewhere", imageURL: nil, audioClips: elsewhereClips)
    let otherAudioClipCategory = AudioClipCategory(title: "Other", imageURL: nil, audioClips: otherClips)
    // highlight-categories

    // Create a `Configuration` object.
    // highlight-configure
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      let assetCatalog = AssetCatalog.defaultItems

      // Add the custom audio clips to the asset catalog.
      assetCatalog.audioClips = [elsewhereAudioClipCategory, otherAudioClipCategory]

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
