import UIKit
import VideoEditorSDK

class VideoCameraConfigurationSwift: Example {
  override func invokeExample() {
    // Create a `Configuration` object.
    //
    // For replacing the live filters of the camera please see the
    // examples at Filters/AddFilters.
    let configuration = Configuration { builder in
      builder.configureCameraViewController { options in
        // By default the camera view controller does not show a cancel button,
        // so that it can be embedded into any other view controller. But since it is
        // presented modally here, a cancel button should be visible.
        // highlight-show-cancel
        options.showCancelButton = true
        // highlight-show-cancel

        // By default the camera view controller allows to both record a video as well as
        // take a photo. Since we are only using VE.SDK here, taking a photo should not
        // be allowed.
        // highlight-modes
        options.allowedRecordingModes = [.video]
        // highlight-modes

        // By default the camera view controller allows all camera positions. The first
        // position will be selected by default.
        // For this example, the camera should open with the front camera first, e.g.
        // for recording a personal vlog.
        // highlight-position
        options.allowedCameraPositions = [.front, .back]
        // highlight-position

        // By default, the camera allows all recording modes. If the current orientation
        // of the device does not match any of the specified orientations the first one
        // of these is used.
        // For this example, we only allow the `.portrait` orientation, e.g. for all
        // social media posts to have the same orientation.
        // highlight-orientation
        options.allowedRecordingOrientations = [.portrait]
        // highlight-orientation
      }
    }

    // Create the camera view controller passing above configuration.
    // The camera only runs on physical devices. On the simulator, only the image picker is enabled.
    let cameraViewController = CameraViewController(configuration: configuration)
    cameraViewController.modalPresentationStyle = .fullScreen

    // The `completionBlock` will be called when the user selects a video from the camera roll
    // or finishes recording a video.
    cameraViewController.completionBlock = { result in
      // You can now use `result.url` for further processing.
      // The `result.data` is not needed since we are only using VE.SDK.
      // Dismissing the camera now.
      guard let url = result.url else { return }
      print("Received video at \(url.absoluteString).")
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // The `cancelBlock` will be called when the user taps the cancel button.
    cameraViewController.cancelBlock = {
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    presentingViewController?.present(cameraViewController, animated: true, completion: nil)
  }
}
