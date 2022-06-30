import UIKit
import VideoEditorSDK

class EmbedVideoEditorUIKitSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create the video editor. Make this class the delegate of it to handle export and cancelation.
    // highlight-create-editor
    let videoEditViewController = VideoEditViewController(videoAsset: video)
    videoEditViewController.delegate = self
    // highlight-create-editor

    // Create and present a navigation controller that hosts the video editor.
    // The video editor will now use the navigation controller's navigation bar for its cancel and save
    // buttons instead of its own toolbar.
    // If the video editor is the navigation controller's root view controller, it will display the close
    // button on the left side of the navigation bar and call `videoEditViewControllerDidCancel(_:)` when
    // the user taps on it.
    // If the video editor is *not* the navigation controller's root view controller, it will display the
    // regular back button on the left side of the navigation bar and will *not* call
    // `videoEditViewControllerDidCancel(_:)` when tapping on it.
    // highlight-embed
    let navigationController = UINavigationController(rootViewController: videoEditViewController)
    navigationController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(navigationController, animated: true, completion: nil)
    // highlight-embed
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
