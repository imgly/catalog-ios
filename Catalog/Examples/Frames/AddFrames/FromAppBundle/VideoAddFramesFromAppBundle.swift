import UIKit
import VideoEditorSDK

class VideoAddFramesFromAppBundleSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `CustomPatchConfiguration` to specify images for a custom frame.
    // highlight-custom-patch
    let frameConfiguration = CustomPatchConfiguration()
    // highlight-custom-patch

    // Add `FrameImageGroup`s to the frame configuration.
    // For this example the custom frame has images assigned for each side.
    // However, the frame only needs to have one `FrameImageGroup` assigned.
    // highlight-image-groups
    frameConfiguration.leftImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: Bundle.main.url(forResource: "imgly_frame_lowpoly_left", withExtension: "png")!, endImageURL: nil)
    frameConfiguration.rightImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: Bundle.main.url(forResource: "imgly_frame_lowpoly_right", withExtension: "png")!, endImageURL: nil)

    let bottomStartImageURL = Bundle.main.url(forResource: "imgly_frame_lowpoly_bottom_left", withExtension: "png")!
    let bottomEndImageURL = Bundle.main.url(forResource: "imgly_frame_lowpoly_bottom_right", withExtension: "png")!
    let bottomMidImageURL = Bundle.main.url(forResource: "imgly_frame_lowpoly_bottom", withExtension: "png")!
    frameConfiguration.bottomImageGroup = FrameImageGroup(startImageURL: bottomStartImageURL, midImageURL: bottomMidImageURL, endImageURL: bottomEndImageURL)

    let topStartImageURL = Bundle.main.url(forResource: "imgly_frame_lowpoly_top_left", withExtension: "png")!
    let topEndImageURL = Bundle.main.url(forResource: "imgly_frame_lowpoly_top_right", withExtension: "png")!
    let topMidImageURL = Bundle.main.url(forResource: "imgly_frame_lowpoly_top", withExtension: "png")!
    frameConfiguration.topImageGroup = FrameImageGroup(startImageURL: topStartImageURL, midImageURL: topMidImageURL, endImageURL: topEndImageURL)
    // highlight-image-groups

    // By default the `midImageMode` is set to `.repeat` which repeats
    // the middle image to fill out the entire space.
    // For this example it is set to `.stretch` for all image groups
    // to keep the correct pattern. In this mode, the middle image is
    // stretched to fill out the entire space.
    // highlight-image-modes
    frameConfiguration.topImageGroup?.midImageMode = .stretch
    frameConfiguration.leftImageGroup?.midImageMode = .stretch
    frameConfiguration.rightImageGroup?.midImageMode = .stretch
    frameConfiguration.bottomImageGroup?.midImageMode = .stretch
    // highlight-image-modes

    // Create a `CustomPatchFrameBuilder` responsible to render a custom frame.
    // highlight-frame
    let frameBuilder = CustomPatchFrameBuilder(configuration: frameConfiguration)

    // Create a custom `Frame`.
    let customFrame = Frame(frameBuilder: frameBuilder, relativeScale: 0.05, thumbnailURL: Bundle.main.url(forResource: "imgly_frame_lowpoly_thumbnail", withExtension: "png")!, identifier: "imgly_frame_lowpoly")
    // highlight-frame

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      let assetCatalog = AssetCatalog.defaultItems

      // Add the custom frame to the asset catalog.
      // highlight-config
      assetCatalog.frames.append(customFrame)
      // highlight-config

      // Use the new asset catalog for the configuration.
      builder.assetCatalog = assetCatalog
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
