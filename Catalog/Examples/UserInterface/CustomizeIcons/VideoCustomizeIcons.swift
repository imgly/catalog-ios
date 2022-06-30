import UIKit
import VideoEditorSDK

// Helper extension for replacing default icons with custom icons.
// highlight-extension
private extension UIImage {
  /// Create a new icon image for a specific size by centering the input image and optionally applying alpha blending.
  /// - Parameters:
  ///   - pt: Icon size in point (pt).
  ///   - alpha: Icon alpha value.
  /// - Returns: A new icon image.
  func icon(pt: CGFloat, alpha: CGFloat = 1) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: pt, height: pt), false, scale)
    let position = CGPoint(x: (pt - size.width) / 2, y: (pt - size.height) / 2)
    draw(at: position, blendMode: .normal, alpha: alpha)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
}
// highlight-extension

class VideoCustomizeIconsSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // This example replaces some of the default icons with symbol images provided by SF Symbols.
    // Create a symbol configuration with scale variant large as the default is too small for our use case.
    // highlight-config
    let config = UIImage.SymbolConfiguration(scale: .large)
    // highlight-config

    // Set up the image replacement closure (once) before the editor is initialized.
    // highlight-bundle-image
    IMGLY.bundleImageBlock = { imageName in
      // highlight-bundle-image
      // Print the image names that the SDK is requesting at run time. This allows to interact with the editor and
      // to identify the image names of icons that should be replaced. Alternatively, all default assets can be found
      // in the `ImglyKit.bundle` located within the `ImglyKit.framework`s, e.g., in the directory:
      // `ImglyKit.xcframework/ios-arm64/ImglyKit.framework/ImglyKit.bundle/`
      print(imageName)

      // Return replacement images for the requested image name.
      // Most icon image names use the `pt` postfix which states the expected dimensions for the used image measured
      // in points (pt), e.g., the postfix `_48pt` stands for an image of 48x48 pixels for scale factor 1.0 and 96x96
      // pixels (@2x) as well as 144x144 pixels (@3x) for its high-resolution variants.
      // highlight-switch
      switch imageName {

      // Replace the cancel, approve, and save icons which should have a pre-applied alpha of 0.6 to match the default
      // toolbar appearance.
      case "imgly_icon_cancel_44pt":
        return UIImage(systemName: "multiply.circle.fill", withConfiguration: config)?.icon(pt: 44, alpha: 0.6)
      case "imgly_icon_approve_44pt":
        return UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)?.icon(pt: 44, alpha: 0.6)
      case "imgly_icon_save":
        return UIImage(systemName: "arrow.down.circle.fill", withConfiguration: config)?.icon(pt: 44, alpha: 0.6)

      // Replace the undo and redo icons.
      case "imgly_icon_undo_48pt":
        return UIImage(systemName: "arrow.uturn.backward", withConfiguration: config)?.icon(pt: 48)
      case "imgly_icon_redo_48pt":
        return UIImage(systemName: "arrow.uturn.forward", withConfiguration: config)?.icon(pt: 48)

      // Replace the play/pause and sound on/off icons.
      case "imgly_icon_play_48pt":
        return UIImage(systemName: "play.fill", withConfiguration: config)?.icon(pt: 48)
      case "imgly_icon_pause_48pt":
        return UIImage(systemName: "pause.fill", withConfiguration: config)?.icon(pt: 48)
      case "imgly_icon_sound_on_48pt":
        return UIImage(systemName: "speaker.wave.2.fill", withConfiguration: config)?.icon(pt: 48)
      case "imgly_icon_sound_off_48pt":
        return UIImage(systemName: "speaker.slash.fill", withConfiguration: config)?.icon(pt: 48)

      // Returning `nil` will use the default icon image.
      default:
        return nil
      }
      // highlight-switch
    }

    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
    let videoEditViewController = VideoEditViewController(videoAsset: video)
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
