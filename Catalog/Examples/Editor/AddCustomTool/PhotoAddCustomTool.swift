import PhotoEditorSDK
import UIKit

class PhotoAddCustomToolSwift: Example, PhotoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create a `Configuration` object.
    // highlight-configure-menu-items
    let configuration = Configuration { builder in
      // Configure the `PhotoEditViewController`.
      builder.configurePhotoEditViewController { options in
        // Add the custom menu item.
        options.menuItems = [createCustomToolMenuItem()] + PhotoEditMenuItem.defaultItems
      }
    }
    // highlight-configure-menu-items

    // Create and present the photo editor. Make this class the delegate of it to handle export and cancelation.
    let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
    photoEditViewController.delegate = self
    photoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
  }

  // Create a custom `PhotoEditMenuItem` for the custom annotation tool.
  // highlight-menu-items
  private func createCustomToolMenuItem() -> PhotoEditMenuItem {
    let iconURL = Bundle.imgly.resourceBundle.url(forResource: "imgly_icon_tool_brush_48pt", withExtension: "png")!
    let iconData = try? Data(contentsOf: iconURL)
    let icon = UIImage(data: iconData!)

    return .tool(ToolMenuItem(title: "Annotation", icon: icon!, toolControllerClass: CustomToolController.self, supportsPhoto: true, supportsVideo: false)!)
  }
  // highlight-menu-items

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

// A custom subclass of `MenuListSectionController` which controls
// the `UICollectionView` menu of the custom tool.
// highlight-section-controller
private class AnnotationListSectionController: MenuListSectionController {
  // The contained `AnnotationMenuItem`.
  private var annotationMenuItem: AnnotationMenuItem?

  // Return a dequeued cell for a given index.
  open override func cellForItem(at index: Int) -> UICollectionViewCell {
    guard let cell = super.cellForItem(at: index) as? MenuCollectionViewCell,
          let annotationMenuItem = annotationMenuItem else {
      fatalError()
    }

    cell.iconImageView.image = UIImage(color: annotationMenuItem.color, size: CGSize(width: 44, height: 44), cornerRadius: 22)
    cell.captionTextLabel.text = annotationMenuItem.title

    return cell
  }

  // Updates the section controller to a new object.
  open override func didUpdate(to object: Any) {
    super.didUpdate(to: object)

    if let annotationMenuItem = object as? AnnotationMenuItem {
      self.annotationMenuItem = annotationMenuItem
    }
  }
}
// highlight-section-controller

// A custom `MenuItem` used to display the various annotation
// pens in the menu of the `CustomToolController`.
// highlight-annotation-menu-item
private class AnnotationMenuItem: NSObject, MenuItem {
  // The title of the pen.
  let title: String

  // The color of the pen.
  let color: UIColor

  // The hardness of the pen.
  let hardness: CGFloat

  // The size of the pen stroke.
  let size: CGFloat

  // Initializes a new `AnnotationMenuItem` with all available
  // properties.
  init(title: String, color: UIColor, hardness: CGFloat, size: CGFloat) {
    self.title = title
    self.color = color
    self.hardness = hardness
    self.size = size
    super.init()
  }

  // The unique identifier.
  var diffIdentifier: NSObjectProtocol {
    self
  }

  // Determines whether the instance is equal to another `Diffable`.
  func isEqual(toDiffableObject object: Diffable?) -> Bool {
    guard self !== object else { return true }
    guard let object = object as? AnnotationMenuItem else { return false }

    return title == object.title
      && color == object.color
      && hardness == object.hardness
      && size == object.size
  }

  // Determines the `MenuListSectionController` type for the menu.
  static var sectionControllerType: MenuListSectionController.Type {
    AnnotationListSectionController.self
  }
}
// highlight-annotation-menu-item

// A custom tool controller used for annotation.
// highlight-tool-controller
private class CustomToolController: BrushToolController {

  override func viewDidLoad() {
    // Add custom menu items to the menu.
    menuViewController.menuItems = [
      AnnotationMenuItem(title: "Highlight", color: UIColor.yellow, hardness: 0.5, size: 20),
      AnnotationMenuItem(title: "White Out", color: UIColor.white, hardness: 0.6, size: 5),
      AnnotationMenuItem(title: "Black Pen", color: UIColor.black, hardness: 0.7, size: 10),
      AnnotationMenuItem(title: "Blue Pen", color: UIColor.blue, hardness: 0.8, size: 50),
      AnnotationMenuItem(title: "Red Pen", color: UIColor.red, hardness: 0.9, size: 1),
      AnnotationMenuItem(title: "Custom", color: UIColor.white, hardness: 1, size: 1)
    ]
    menuViewController.reloadData(completion: nil)
    brushEditController.sliderEditController.slider.neutralValue = 1
    brushEditController.sliderEditController.slider.maximumValue = 100
    brushEditController.sliderEditController.slider.minimumValue = 1
    brushEditController.activeBrushTool = .size

    super.viewDidLoad()
  }

  // Configure the toolbar to display the tool name.
  override func configureToolbarItem() {
    super.configureToolbarItem()

    guard let toolbarItem = toolbarItem as? DefaultToolbarItem else {
      return
    }

    toolbarItem.titleLabel.attributedText = NSAttributedString(
      string: "ANNOTATION",
      attributes: [
        .kern: 1.2,
        .font: UIFont.systemFont(ofSize: 12, weight: .medium)
      ]
    )
  }
  // highlight-tool-controller

  // Define what the tool should do if one of the menu items has been selected.
  // highlight-menu-view-controller
  override func menuViewController(_ menuViewController: MenuViewController, didSelect menuItem: MenuItem) {
    guard let menuItem = menuItem as? AnnotationMenuItem else {
      return
    }

    if menuItem.title == "Custom" {
      let brushToolController = BrushToolController(configuration: configuration, productType: .pesdk)!
      notifySubscribers { $0.photoEditToolController(self, wantsToPresent: brushToolController) }
    } else {
      brushEditController.hardness = menuItem.hardness
      brushEditController.color = menuItem.color
      brushEditController.size = menuItem.size
      brushEditController.sliderEditController.slider.value = menuItem.size
    }

    super.menuViewController(menuViewController, didSelect: menuItem)
  }
  // highlight-menu-view-controller
}

private extension UIImage {
  // Generates an `UIImage` with a given color, size and corner radius.
  convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), cornerRadius: CGFloat = 0.0) {
    let rect = CGRect(origin: .zero, size: size)
    let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    path.fill()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
  }
}
