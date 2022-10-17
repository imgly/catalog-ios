import PhotoEditorSDK
import UIKit

class PhotoCustomizeSingleToolUseSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure settings related to the `PhotoEditViewController`.
      builder.configurePhotoEditViewController { options in
        // Configure the tool menu item to be displayed as single tool.
        // Make sure your license includes the tool you want to use.
        // highlight-configure
        options.menuItems = [
          // Create one of the supported tools.
          // We will create a filter tool.
          ToolMenuItem.createFilterToolItem()
          // ToolMenuItem.createTransformToolItem()
          // ToolMenuItem.createAdjustToolItem()
          // ToolMenuItem.createFocusToolItem()
          // ToolMenuItem.createOverlayToolItem()
          // ToolMenuItem.createBrushToolItem()
        ].compactMap { menuItem in
          // Convert `MenuItem`s to `PhotoEditMenuItem`s.
          guard let menuItem = menuItem else { return nil }
          return .tool(menuItem)
        }
        // highlight-configure
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
