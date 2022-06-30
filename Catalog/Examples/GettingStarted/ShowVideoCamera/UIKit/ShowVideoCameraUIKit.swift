import UIKit
import VideoEditorSDK

class ShowVideoCameraUIKitSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Configuration` object.
    // highlight-configuration
    let configuration = Configuration { builder in
      builder.configureCameraViewController { options in
        // By default the camera view controller does not show a cancel button,
        // so that it can be embedded into any other view controller. But since it is
        // presented modally here, a cancel button should be visible.
        options.showCancelButton = true

        // Enable video only.
        options.allowedRecordingModes = [.video]
      }
    }

    // Create the camera view controller passing above configuration.
    let cameraViewController = CameraViewController(configuration: configuration)
    // highlight-configuration

    // The `cancelBlock` will be called when the user taps the cancel button.
    // highlight-cancel-block
    cameraViewController.cancelBlock = { [weak self] in
      // Dismiss the camera view controller.
      self?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    // highlight-cancel-block

    // The `completionBlock` will be called when the user selects a video from the camera roll
    // or finishes recording a video.
    // highlight-completion-block
    cameraViewController.completionBlock = { [weak self] result in
      // Create a `Video` from the `URL` object.
      guard let url = result.url else { return }
      let video = Video(url: url)

      // Dismiss the camera view controller and open the video editor after dismissal.
      self?.presentingViewController?.dismiss(animated: true, completion: {
        // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
        // Passing the `result.model` to the editor to preserve selected filters.
        let videoEditViewController = VideoEditViewController(videoAsset: video, photoEditModel: result.model)
        videoEditViewController.delegate = self
        videoEditViewController.modalPresentationStyle = .fullScreen
        self?.presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
      })
    }
    // highlight-completion-block

    // Present the camera view controller.
    // To take photos, the camera will require the `NSCameraUsageDescription` key to be present in your Info.plist file.
    // To access photos in the camera roll, the camera will require the `NSPhotoLibraryUsageDescription` key to be present in your Info.plist file.
    // To record videos, the camera will require the `NSMicrophoneUsageDescription` key to be present in your Info.plist file.
    // highlight-present
    cameraViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(cameraViewController, animated: true, completion: nil)
    // highlight-present
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
