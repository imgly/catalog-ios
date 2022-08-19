import UIKit
import VideoEditorSDK

class VideoTextConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TextToolController` which lets the user
      // add text to the video.
      builder.configureTextToolController { options in
        // By default the text alignment is set to `NSTextAlignment.center`.
        // In this example, the default text orientation is set to `NSTextAlignment.left`.
        // highlight-text-align
        options.defaultTextAlignment = .left
        // highlight-text-align

        // By default the editor allows to add emojis as text input.
        // Since emojis are not cross-platform compatible, using the serialization
        // feature to share edits across different platforms will result in emojis
        // being rendered with the system's local set of emojis and therefore will
        // appear differently.
        // For this example emoji input is disabled to ensure a consistent cross-platform experience.
        // highlight-emojis
        options.emojisEnabled = false
        // highlight-emojis

        // By default the minimum text size is set to 20pt.
        // For this example the minimum size is reduced.
        // highlight-size
        options.minimumTextSize = 17.0
        // highlight-size
      }

      // Configure the `TextOptionsToolController` which lets the user
      // customize a selected text when added to the canvas.
      builder.configureTextOptionsToolController { options in
        // By default the editor enables all available text actions.
        // For this example only a small selection of text actions
        // should be allowed.
        // highlight-actions
        options.allowedTextActions = [.duration, .selectFont, .selectColor]
        // highlight-actions
      }

      // Configure the `TextFontToolController` which lets the user
      // change the font of the text.
      builder.configureTextFontToolController { options in
        // This closure is executed every time the user selects a font.
        // highlight-font-selection
        options.textFontActionSelectedClosure = { fontName in
          print("Font has been selected with name:", fontName)
        }
        // highlight-font-selection
      }

      // Configure the `TextColorToolController` which lets the user
      // change the color of the text.
      builder.configureTextColorToolController { options in
        // By default the editor provides a variety of different
        // colors to customize the color of the text.
        // For this example only a small selection of colors is shown by default
        // e.g. based on favorite colors of the user.
        // highlight-colors
        options.availableColors = [
          Color(color: UIColor.white, colorName: "White"),
          Color(color: UIColor.black, colorName: "Black")
        ]
        // highlight-colors

        // By default the editor provides a variety of different
        // colors to customize the background color of the text.
        // For this example only a small selection of colors is shown by default
        // e.g. based on favorite colors of the user.
        // highlight-background-colors
        options.availableBackgroundTextColors = [
          Color(color: UIColor.red, colorName: "Red"),
          Color(color: UIColor.green, colorName: "Green"),
          Color(color: UIColor.yellow, colorName: "Yellow")
        ]
        // highlight-background-colors
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
