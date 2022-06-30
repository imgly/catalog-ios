import UIKit
import VideoEditorSDK

class VideoSerializationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    // highlight-setup
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
    let videoEditViewController = VideoEditViewController(videoAsset: video)
    videoEditViewController.delegate = self
    videoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
    // highlight-setup
  }

  // MARK: - VideoEditViewControllerDelegate

  func videoEditViewControllerShouldStart(_ videoEditViewController: VideoEditViewController, task: VideoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func videoEditViewControllerDidFinish(_ videoEditViewController: VideoEditViewController, result: VideoEditorResult) {
    // The user exported a new video successfully and the newly generated video is located at `result.output.url`.

    // To get a `Data` object of all edits which have been applied to a video, you can use the following method.
    // highlight-serialization
    let serializedSettings = videoEditViewController.serializedSettings

    // Optionally, you can convert the serialized settings to a JSON string if needed.
    let jsonString = String(data: serializedSettings!, encoding: .utf8)
    print(jsonString!)

    // Or to a `Dictionary`.
    let jsonDict = try? JSONSerialization.jsonObject(with: serializedSettings!, options: [])
    print(jsonDict! as Any)
    // highlight-serialization

    // You can use either `serializedSettings`, `jsonString`, or `jsonDict` for further processing, such as
    // uploading it to a remote URL or saving it to the filesystem. See `SaveVideoToRemoteURLSwift` or
    // `SaveVideoToFilesystemSwift` to get an idea about the approach to take for this.

    // For loading serialized settings into the editor, please take a look at `VideoDeserializationSwift`.

    // Dismiss the editor.
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
