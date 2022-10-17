import UIKit
import VideoEditorSDK

class VideoCustomizeSingleToolUseSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure settings related to the `VideoEditViewController`.
      builder.configureVideoEditViewController { options in
        // Configure `VideoEditViewController` to be in single tool mode.
        // highlight-configure
        // Configure the tool menu item to be displayed as single tool.
        // Make sure your license includes the tool you want to use.
        options.menuItems = [
          // Create one of the supported tools.
          // We will create composition or trim tool.
          ToolMenuItem.createCompositionOrTrimToolItem()
          // ToolMenuItem.createTrimToolItem()
          // ToolMenuItem.createTransformToolItem()
          // ToolMenuItem.createFilterToolItem()
          // ToolMenuItem.createAdjustToolItem()
          // ToolMenuItem.createFocusToolItem()
          // ToolMenuItem.createOverlayToolItem()
          // ToolMenuItem.createBrushToolItem()
        ].compactMap { menuItem in
          // Convert `MenuItem`s to `PhotoEditMenuItem`s.
          guard let menuItem = menuItem else { return nil }
          return .tool(menuItem)
        }
        // highlight-configure
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
