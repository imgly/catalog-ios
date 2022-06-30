import UIKit
import VideoEditorSDK

class VideoCustomizeMenuItemsSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure settings related to the `VideoEditViewController`.
      // highlight-configure
      builder.configureVideoEditViewController { options in
        // Configure the available tool menu items to be displayed in the main menu.
        // Menu items for tools not included in your license subscription will be hidden automatically.
        options.menuItems = [
          // Create the default `MenuItem`s.
          ToolMenuItem.createCompositionOrTrimToolItem(),
          ToolMenuItem.createAudioToolItem(),
          ToolMenuItem.createTransformToolItem(),
          ToolMenuItem.createFilterToolItem(),
          ToolMenuItem.createAdjustToolItem(),
          ToolMenuItem.createFocusToolItem(),
          ToolMenuItem.createStickerToolItem(),
          ToolMenuItem.createTextToolItem(),
          ToolMenuItem.createTextDesignToolItem(),
          ToolMenuItem.createOverlayToolItem(),
          ToolMenuItem.createFrameToolItem(),
          ToolMenuItem.createBrushToolItem()
        ].compactMap { menuItem in
          // Convert `MenuItem`s to `PhotoEditMenuItem`s.
          guard let menuItem = menuItem else { return nil }
          return .tool(menuItem)
          // highlight-configure
          // highlight-menu
        }.sorted { a, b in
          // Sort the menu items by their title for demonstration purposes.
          func title(_ menuItem: PhotoEditMenuItem) -> String {
            switch menuItem {
            case .tool(let menuItem):
              return menuItem.title
            case .action(let menuItem):
              return menuItem.title
            default:
              return ""
            }
          }
          return title(a) < title(b)
        }
        // highlight-menu
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
