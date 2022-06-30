import PhotoEditorSDK
import UIKit

class PhotoAddFramesFromRemoteURLSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      let assetCatalog = AssetCatalog.defaultItems

      // Create a `CustomPatchConfiguration` to specify images for a custom frame.
      // highlight-custom-patch
      let frameConfiguration = CustomPatchConfiguration()
      // highlight-custom-patch

      // Add `FrameImageGroup`s to the frame configuration.
      //
      // The frame tool is optimized for remote resources which allows to directly
      // integrate a remote URL instead of downloading the asset before. For an
      // example on how to download the remote resources in advance and use the local
      // downloaded resources, see: Examples/Text/AddFonts/FromRemoteURL.
      //
      // For this example the custom frame has images assigned for each side.
      // However, the frame only needs to have one `FrameImageGroup` assigned.
      // highlight-image-groups
      frameConfiguration.leftImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_left.png")!, endImageURL: nil)
      frameConfiguration.rightImageGroup = FrameImageGroup(startImageURL: nil, midImageURL: URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_right.png")!, endImageURL: nil)

      let bottomStartImageURL = URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_bottom_left.png")!
      let bottomEndImageURL = URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_bottom_right.png")!
      let bottomMidImageURL = URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_bottom.png")!
      frameConfiguration.bottomImageGroup = FrameImageGroup(startImageURL: bottomStartImageURL, midImageURL: bottomMidImageURL, endImageURL: bottomEndImageURL)

      let topStartImageURL = URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_top_left.png")!
      let topEndImageURL = URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_top_right.png")!
      let topMidImageURL = URL(string: "https://img.ly/static/example-assets/imgly_frame_lowpoly_top.png")!
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
      let customFrame = Frame(frameBuilder: frameBuilder, relativeScale: 0.05, thumbnailURL: URL(string: "https://www.img.ly/static/example-assets/imgly_frame_lowpoly_thumbnail.png")!, identifier: "imgly_frame_lowpoly")
      // highlight-frame

      // Add the custom frame to the asset catalog.
      // highlight-config
      assetCatalog.frames.append(customFrame)
      // highlight-config

      // Use the new asset catalog for the configuration.
      builder.assetCatalog = assetCatalog
    }

    // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
    photoEditViewController.delegate = self
    photoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
  }

  // MARK: - PhotoEditViewControllerDelegate

  func photoEditViewControllerShouldStart(_ photoEditViewController: PhotoEditViewController, task: PhotoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func photoEditViewControllerDidFinish(_ photoEditViewController: PhotoEditViewController, result: PhotoEditorResult) {
    // The image has been exported successfully and is passed as an `Data` object in the `result.output.data`.
    // To create an `UIImage` from the output, use `UIImage(data:)`.
    // See other examples about how to save the resulting image.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func photoEditViewControllerDidFail(_ photoEditViewController: PhotoEditViewController, error: PhotoEditorError) {
    // There was an error generating the photo.
    print(error.localizedDescription)
    // Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
    // The user tapped on the cancel button within the editor. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
