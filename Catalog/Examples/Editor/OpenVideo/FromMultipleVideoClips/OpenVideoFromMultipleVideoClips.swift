import AVFoundation
import UIKit
import VideoEditorSDK

class OpenVideoFromMultipleVideoClipsSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Get the URLs for video files on the local file system. This could be any file within the app bundle
    // or also a file within the documents or temporary folders for example. This example will use
    // files from the app bundle.
    // highlight-setup
    let firstURL = Bundle.main.url(forResource: "Skater", withExtension: "mp4")!
    let secondURL = Bundle.main.url(forResource: "test_video", withExtension: "mp4")!

    // Create `AVAsset`s from above `URL`s.
    let firstAsset = AVAsset(url: firstURL)
    let secondAsset = AVAsset(url: secondURL)

    // Create a `Video` from above assets.
    let video = Video(assets: [firstAsset, secondAsset])
    // highlight-setup

    // Create a video editor and pass it the video. Make this class the delegate of it to handle export and cancelation.
    // highlight-instantiation
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
