import UIKit
import VideoEditorSDK

class OpenVideoFromAppBundleSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Get the URL for a file on the local file system. This could be any file within the app bundle
    // or also a file within the documents or temporary folders for example. This example will use
    // a file from the app bundle.
    // highlight-bundle-url
    guard let url = Bundle.main.url(forResource: "Skater", withExtension: "mp4") else {
      fatalError("Unable to create URL for specified file.")
    }
    // highlight-bundle-url

    // Create a `Video` from the video URL.
    // highlight-instantiation
    let video = Video(url: url)

    // Create a video editor and pass it the video. Make this class the delegate of it to handle export and cancelation.
    let videoEditViewController = VideoEditViewController(videoAsset: video)
    videoEditViewController.delegate = self
    // highlight-instantiation

    // Present the video editor.
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
