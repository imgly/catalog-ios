import PhotoEditorSDK
import UIKit

class PhotoCustomizeMenuItemsSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Configure settings related to the `PhotoEditViewController`.
      // highlight-configure
      builder.configurePhotoEditViewController { options in
        // Configure the available tool menu items to be displayed in the main menu.
        // Menu items for tools not included in your license subscription will be hidden automatically.
        options.menuItems = [
          // Create the default `MenuItem`s.
          ToolMenuItem.createTransformToolItem(),
          ToolMenuItem.createFilterToolItem(),
          ToolMenuItem.createAdjustToolItem(),
          ToolMenuItem.createFocusToolItem(),
          ToolMenuItem.createStickerToolItem(),
          ToolMenuItem.createTextToolItem(),
          ToolMenuItem.createTextDesignToolItem(),
          ToolMenuItem.createOverlayToolItem(),
          ToolMenuItem.createFrameToolItem(),
          ToolMenuItem.createBrushToolItem(),
          ActionMenuItem.createMagicItem()
        ].compactMap { menuItem in
          // Convert `MenuItem`s to `PhotoEditMenuItem`s.
          switch menuItem {
          case let menuItem as ToolMenuItem:
            return .tool(menuItem)
          case let menuItem as ActionMenuItem:
            return .action(menuItem)
          default:
            return nil
          }
          // highlight-configure
          // highlight-menu
        }.sorted { a, b in
          // Sort the menu items by their title for demonstration purposes.
          func title(_ menuItem: PhotoEditMenuItem) -> String {
            switch menuItem {
            case .tool(let menuItem):
              return menuItem.title
            case .action(let menuItem):
              return menuItem.title
            default:
              return ""
            }
          }
          return title(a) < title(b)
        }
        // highlight-menu
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
