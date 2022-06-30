import UIKit
import VideoEditorSDK

class VideoAddFiltersFromAppBundleSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a custom LUT filter.
    // highlight-custom-filters
    let customLUTFilter = LUTEffect(identifier: "custom_lut_filter", lutURL: Bundle.main.url(forResource: "custom_lut_invert", withExtension: "png"), displayName: "Invert", horizontalTileCount: 5, verticalTileCount: 5)

    // Create a custom DuoTone filter.
    let customDuoToneFilter = DuoToneEffect(identifier: "custom_duotone_filter", lightColor: .yellow, darkColor: .blue, displayName: "Custom")
    // highlight-custom-filters

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      // highlight-catalog
      let assetCatalog = AssetCatalog.defaultItems

      // Add the custom filters to the asset catalog.
      assetCatalog.effects.append(contentsOf: [customLUTFilter, customDuoToneFilter])

      // Use the new asset catalog for the configuration.
      builder.assetCatalog = assetCatalog
      // highlight-catalog

      // Optionally, you can create custom filter groups which group
      // multiple filters into one folder in the filter tool. If you do not
      // create filter groups the filters will appear independent of each
      // other.
      //
      // Create the thumbnail for the filter group.
      // highlight-groups
      let thumbnailURL = Bundle.main.url(forResource: "custom_filter_category", withExtension: "jpg")!
      let thumbnailData = try? Data(contentsOf: thumbnailURL)
      let thumbnail = UIImage(data: thumbnailData!)

      // Create the actual filter group.
      let customFilterGroup = Group(identifier: "custom_filter_category", displayName: "Custom", thumbnail: thumbnail, memberIdentifiers: ["custom_lut_filter"])

      // Add the custom filter group to the filter tool.
      builder.configureFilterToolController { options in
        options.filterGroups.append(customFilterGroup)
      }
      // highlight-groups
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
