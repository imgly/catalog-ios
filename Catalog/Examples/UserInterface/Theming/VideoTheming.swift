import UIKit
import VideoEditorSDK

class VideoThemingSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // The recommended way to change the appearance of the UI elements is by configuring the `Theme`.
      // The default is a dark color theme but there is also a predefined light color theme. Here we
      // use a theme that switches dynamically between the light and the dark theme based on the active
      // `UITraitCollection.userInterfaceStyle`.
      // highlight-light-dark
      builder.theme = .dynamic
      // highlight-light-dark

      // The base colors of the UI elements can be customized at a central place by modifying the properties of the theme.
      // Use a static color.
      // highlight-colors
      builder.theme.backgroundColor = .darkGray
      // Use system colors that automatically adapt to the current trait environment.
      builder.theme.menuBackgroundColor = .secondarySystemBackground
      builder.theme.toolbarBackgroundColor = .tertiarySystemBackground
      builder.theme.primaryColor = .label
      // Define and use a custom color that automatically adapts to the current trait environment.
      builder.theme.tintColor = UIColor { $0.userInterfaceStyle == .dark ? .green : .red }
      // highlight-colors

      // This closure is called after the theme was applied via `UIAppearance` proxies during the initialization of a `CameraViewController` or a `MediaEditViewController` subclass.
      // It is intended to run custom calls to `UIAppearance` proxies to customize specific UI components. The API documentation highlights when a specific property can be configured
      // with the `UIAppearance` proxy API.
      // highlight-ui-elements
      builder.appearanceProxyConfigurationClosure = { theme in
        // highlight-ui-elements
        // The immutable active theme is passed to this closure and can be used to configure appearance properties.
        // Change the appearance of all overlay buttons.
        // highlight-overlay-buttons
        OverlayButton.appearance(whenContainedInInstancesOf: [MediaEditViewController.self]).tintColor = theme.tintColor
        OverlayButton.appearance().backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        // highlight-overlay-buttons

        // Change the appearance of all menu cells.
        // highlight-menu-cells
        MenuCollectionViewCell.appearance().selectionBorderWidth = 3
        MenuCollectionViewCell.appearance().cornerRadius = 5
        // highlight-menu-cells
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
