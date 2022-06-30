import UIKit
import VideoEditorSDK

class VideoSnapping: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the snapping of all sprites globally in the editor.
      //
      // For this example the editor's snapping behavior is configured
      // to act as a guide for the user to see where the sprites should
      // be placed. A use case could be that an application displays
      // the videos both in rectangular as well as in circular
      // shapes which requires the editor to indicate where the area
      // is in which sprites' visibility is best.
      builder.configureSnapping { options in
        // By default the snapping is enabled when rotating a sprite.
        // For this example this behavior is disabled since only the
        // outer positional snapping guides are needed.
        // highlight-rotation
        options.rotationSnappingEnabled = false
        // highlight-rotation

        // By default the center of the sprite snaps to a vertical
        // line indicating the center of the video.
        // For this example this behavior is disabled since only the
        // outer positional snapping guides are needed.
        // highlight-vertical-line
        options.snapToVerticalCenterLine = false
        // highlight-vertical-line

        // By default the center of the sprite snaps to a horizontal
        // line indicating the center of the video.
        // For this example this behavior is disabled since only the
        // outer positional snapping guides are needed.
        // highlight-horizontal-line
        options.snapToHorizontalCenterLine = false
        // highlight-horizontal-line

        // By default the sprite snaps to a horizontal line
        // on the bottom of the video. This value is measured in normalized
        // coordinates relative to the smaller side of the edited video and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the video.
        // highlight-positional
        options.snapToBottom = 0.15

        // By default the sprite snaps to a horizontal line
        // on the top of the video. This value is measured in normalized
        // coordinates relative to the smaller side of the edited video and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the video.
        options.snapToTop = 0.15

        // By default the sprite snaps to a vertical line
        // on the left of the video. This value is measured in normalized
        // coordinates relative to the smaller side of the edited video and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the video.
        options.snapToLeft = 0.15

        // By default the sprite snaps to a vertical line
        // on the right of the video. This value is measured in normalized
        // coordinates relative to the smaller side of the edited video and
        // defaults to 10% (0.1).
        // For this example the value is set to 15% (0.15) to define the
        // visibility area of the video.
        options.snapToRight = 0.15
        // highlight-positional
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
