import UIKit
import VideoEditorSDK

class VideoEditorConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      builder.configureVideoEditViewController { options in
        // By default the editor allows to zoom the video in the preview.
        // For this example, this behavior is disabled.
        options.allowsPreviewImageZoom = false

        // By default the editor has insets of 12 pt for each side - except for top
        // since this value is ignored.
        // For this example the insets are set to increase the spacing.
        options.overlayButtonInsets = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)

        // By default the editor exports the video in MP4 format.
        // For this example the editor should export the video as MOV.
        options.videoContainerFormat = .mov

        // By default the editor exports with a `.h264(withBitRate: nil)` codec.
        // For this example, the editor should use an average bit rate of 8500 kbp/s.
        options.videoCodec = .h264(withBitRate: 8_500_000)
      }
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
