import UIKit
import VideoEditorSDK

class SaveVideoToBase64Swift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    // highlight-setup
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
    let videoEditViewController = VideoEditViewController(videoAsset: video)
    videoEditViewController.delegate = self
    videoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
    // highlight-setup
  }

  // MARK: - VideoEditViewControllerDelegate

  func videoEditViewControllerShouldStart(_ videoEditViewController: VideoEditViewController, task: VideoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  // highlight-video-export-delegate
  func videoEditViewControllerDidFinish(_ videoEditViewController: VideoEditViewController, result: VideoEditorResult) {
    // highlight-video-export-delegate
    // The user exported a new video successfully and the newly generated video is located at `result.output.url`.
    // If **no modifications** have been made to the original video, we will not process the original video at all
    // and also not reencode it. In this case `result.output.url` will point to the original video that was passed to the editor,
    // if available. If you want to ensure that the original video is always reencoded, even if no modifications have
    // been made to it, you can set `VideoEditViewControllerOptions.forceExport` to `true`, in which case `result.output.url` will
    // always point to a newly generated video.

    // Load file into memory. This could fail for large videos.
    // In general we do not recommend loading the whole file into memory,
    // because video files can get quite large. Use this with caution.
    // highlight-load-into-memory
    let videoData = try? Data(contentsOf: result.output.url)

    // Delete the video on disk. If the video was passed without rendering, we won't delete the file.
    // In production this check would not be needed because the app bundle is read-only.
    // Unfortunately, with the Simulator it is not read-only so we need to include this check
    // or the example will crash when opened a second time.
    if result.status != .passedWithoutRendering {
      try? FileManager.default.removeItem(at: result.output.url)
    }
    // highlight-load-into-memory

    // Convert to Base64 encoded string. Again, this is not recommended for large video files because
    // it will load even more data into memory.
    // highlight-to-base-64
    let base64EncodedString = videoData!.base64EncodedString()
    // highlight-to-base-64

    // You can now use `base64EncodedString` for further processing. Dismissing the editor now.
    print("Received Base64 encoded string with \(base64EncodedString.count) characters")

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
