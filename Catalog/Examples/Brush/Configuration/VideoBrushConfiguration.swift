import UIKit
import VideoEditorSDK

class VideoBrushConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `BrushToolController` which lets the user
      // draw on the video.
      builder.configureBrushToolController { options in
        // By default all available brush tools are enabled.
        // For this example only a couple are enabled.
        // highlight-tools
        options.allowedBrushTools = [.color, .size]
        // highlight-tools

        // By default the default color for the brush stroke is
        // `UIColor.white`. For this example the default color
        // is set to `UIColor.black`.
        // highlight-color
        options.defaultBrushColor = UIColor.black
        // highlight-color

        // By default the default brush size is set to 5% of the
        // smaller side of the video.
        // For this example the default size should be absolute.
        // highlight-size
        options.defaultBrushSize = FloatValue.absolute(5.0)
        // highlight-size
      }

      // Configure the `BrushColorToolController` which lets the user
      // change the color of the brush stroke.
      builder.configureBrushColorToolController { options in
        // By default the editor provides a variety of different
        // colors to customize the color of the brush stroke.
        // For this example only a small selection of colors is enabled.
        // highlight-colors
        options.availableColors = [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black"),
          Color(color: UIColor.red, colorName: "Red")
        ]
        // highlight-colors
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
