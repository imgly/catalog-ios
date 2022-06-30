import Photos
import UIKit
import VideoEditorSDK

class SaveVideoToCameraRollSwift: Example, VideoEditViewControllerDelegate {
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

    // Request access to save to the user's camera roll.
    // highlight-request-authorization
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
      if status != .authorized {
        // Authorization hasn't been granted. In production you could now for example show an alert asking the user
        // to open their Settings.app to grant permissions. Dismissing the editor.
        print("Authorization to write to the camera roll has not been granted.")
        self?.presentingViewController?.dismiss(animated: true, completion: nil)
        return
      }
      // highlight-request-authorization

      // Perform changes in the shared photo library.
      // highlight-move-video
      PHPhotoLibrary.shared().performChanges {
        // Create a `PHAssetCreationRequest`.
        let assetCreationRequest = PHAssetCreationRequest.forAsset()

        // Move the video file instead of copying if possible, so that we don't have to delete it manually.
        // If you wish to keep the original file, you don't need this.
        // If the video wasn't modified, we won't move the file.
        // In production this check would not be needed because the app bundle is read-only.
        // Unfortunately, with the Simulator it is not read-only so we need to include this check
        // or the example will crash when opened a second time.
        let options = PHAssetResourceCreationOptions()
        if result.status != .passedWithoutRendering {
          options.shouldMoveFile = true
        }

        // Add the video file.
        assetCreationRequest.addResource(with: .video, fileURL: result.output.url, options: options)
      } completionHandler: { success, error in
        // highlight-move-video
        // highlight-completion
        if success {
          print("Successfully saved video to camera roll.")
        } else if let error = error {
          print("Error saving video to camera roll: \(error)")
        }

        // Dispatching to the main queue and dismissing the editor.
        DispatchQueue.main.async { [weak self] in
          self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
      }
      // highlight-completion
    }
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
