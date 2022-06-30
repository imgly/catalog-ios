import PhotoEditorSDK
import UIKit

class PhotoThemingSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

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
