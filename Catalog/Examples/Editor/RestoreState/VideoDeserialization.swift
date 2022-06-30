import UIKit
import VideoEditorSDK

class VideoDeserializationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a default `Configuration` with default `AssetCatalog`.
    let configuration = Configuration { builder in
      builder.assetCatalog = AssetCatalog.defaultItems
    }

    // Load the serialized settings from the app bundle. You could also load this from a remote URL for example.
    // See `OpenVideoFromRemoteURLSwift` to get an idea about the approach to take for this.
    // highlight-load-settings
    let serializedSettings = try? Data(contentsOf: Bundle.main.url(forResource: "video_serialization", withExtension: "json")!)
    // highlight-load-settings

    // Deserialize the serialized settings. If you're not sure that the aspect ratio of the current video and the
    // video used when creating the serialized settings are identical, you should specify the size of the video to
    // apply the edits on.
    // highlight-deserialize
    let deserializationResult = Deserializer.deserialize(data: serializedSettings!, imageDimensions: video.size, assetCatalog: configuration.assetCatalog)

    // Get the `PhotoEditModel` from the deserialization result.
    let photoEditModel = deserializationResult.model!

    // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
    // Pass the deserialized `PhotoEditModel` to the editor.
    let videoEditViewController = VideoEditViewController(videoAsset: video, configuration: configuration, photoEditModel: photoEditModel)
    // highlight-deserialize
    videoEditViewController.delegate = self
    videoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(videoEditViewController, animated: true, completion: nil)

    // For saving edits, please take a look at `VideoSerializationSwift`.
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
