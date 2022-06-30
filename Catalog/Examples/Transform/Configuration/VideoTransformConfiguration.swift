import UIKit
import VideoEditorSDK

class VideoTransformConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure the `TransformToolController` that lets the user
      // crop and rotate the video.
      builder.configureTransformToolController { options in
        // By default the editor has a lot of crop aspects enabled.
        // For this example only a couple are enabled, e.g. if you
        // only allow certain video aspects in your application.
        // highlight-crop-ratios
        options.allowedCropRatios = [
          CropAspect(width: 1, height: 1),
          CropAspect(width: 16, height: 9, localizedName: "Landscape")
        ]
        // highlight-crop-ratios

        // By default the editor allows to use a free crop ratio.
        // For this example this is disabled to ensure that the video
        // has a suitable ratio.
        // highlight-free-crop
        options.allowFreeCrop = false
        // highlight-free-crop

        // By default the editor shows the reset button which resets
        // the applied transform operations. In this example the button
        // is hidden since we are enforcing certain ratios and the user
        // can only select among them anyway.
        // highlight-reset-button
        options.showResetButton = false
        // highlight-reset-button
      }

      // Configure the `VideoEditViewController`.
      builder.configureVideoEditViewController { options in
        // For this example the user is forced to crop the asset to one of
        // the allowed crop aspects specified above, before being able to use other
        // features of the editor. The transform tool will only be presented
        // if the video does not already fit one of those allowed aspect ratios.
        // highlight-force-crop
        options.forceCropMode = true
        // highlight-force-crop
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
