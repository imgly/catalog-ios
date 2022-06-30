import UIKit
import VideoEditorSDK

class TrimEnforceDurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TrimToolController` that lets the user
      // trim the video. The duration limits of these configuration options are
      // also respected by the `CompositionToolController`.
      builder.configureTrimToolController { options in
        // By default the editor does not have a maximum duration.
        // For this example the duration is set, e.g. for a social
        // media application where the posts are not allowed to be
        // longer than 4 seconds.
        options.maximumDuration = 4.0

        // By default the editor does not limit the maximum video duration.
        // For this example the duration is set, e.g. for a social
        // media application where the posts are not allowed to be
        // shorter than 2 seconds.
        options.minimumDuration = 2.0
      }

      // Configure the `VideoEditViewController`.
      // highlight-force-trim
      builder.configureVideoEditViewController { options in
        // By default the editor trims the video automatically if it is
        // longer than the specified maximum duration. For this example the user
        // is prompted to review and adjust the automatically trimmed video.
        options.forceTrimMode = .ifNeeded
      }
      // highlight-force-trim
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
