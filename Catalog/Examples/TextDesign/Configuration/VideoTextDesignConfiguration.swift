import UIKit
import VideoEditorSDK

class VideoTextDesignConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TextDesignToolController` that lets the user
      // add text designs to the video.
      builder.configureTextDesignToolController { options in
        // By default the editor allows to add emojis as text input.
        // Since emojis are not cross-platform compatible, using the serialization
        // feature to share edits across different platforms will result in emojis
        // being rendered with the system's local set of emojis and therefore will
        // appear differently.
        // For this example emoji input is disabled to ensure a consistent cross-platform experience.
        // highlight-emojis
        options.emojisEnabled = false
        // highlight-emojis

        // By default the editor provides a `ColorPalette` with a lot of colors.
        // For this example this will be replaced with a `ColorPalette`
        // with only a few colors enabled.
        // highlight-color
        options.colorPalette = ColorPalette(colors: [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black")
        ])
        // highlight-color
      }

      // Configure the `TextDesignOptionsToolController` that lets the user
      // change text designs that have been placed on top of the video.
      // highlight-actions
      builder.configureTextDesignOptionsToolController { options in
        // By default the editor has all available overlay actions for this tool
        // enabled. For this example `TextDesignOverlayAction.undo` and `TextDesignOverlayAction.redo`
        // are removed.
        options.allowedTextDesignOverlayActions = [.add, .bringToFront, .delete, .invert]
      }
      // highlight-actions
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
