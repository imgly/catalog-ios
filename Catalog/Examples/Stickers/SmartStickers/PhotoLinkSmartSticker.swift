import PhotoEditorSDK
import UIKit

extension PhotoLinkSmartSticker {
  // highlight-sticker-definition
  /// Custom `SmartSticker` that will present a prompt when sticker is selected.
  ///
  /// In this example we will create a link sticker that allows us to enter a link, that will then be rendered next to an icon
  /// in a prettyfied form. Full link  that was entered or copied to the prompt will be available in the field `metadata` on
  /// `StickerSpriteModel` when the sticker is placed so it can be used in a later stage for processing along with other data.
  @objc(PLinkSmartSticker) class LinkSmartSticker: SmartSticker {
    // highlight-sticker-definition

    // We will define multiple properties that will be used when rendering
    // the sticker. Some are constant and are not changing between variations.
    // highlight-sticker-props

    // Corner radius of the background box.
    private let cornerRadius = 10
    // Font size used for link text.
    private let fontSize = 17.0
    // Content padding.
    private let padding: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)

    private let iconSize = CGSize(width: 24, height: 24)

    // A text that will be shown when no metadata is provided which is when
    // preview sticker is being rendered.
    private let previewText: String = "Link".uppercased()

    // Three variable properties that are different between variations.
    // We pass these through the constructor.
    let textColor: UIColor
    let boxColor: UIColor
    let iconColor: UIColor

    // highlight-sticker-props
    // highlight-sticker-prompt
    // A prompt that will be presented when sticker is selected in the sticker
    // selection view. It must implement `SmartSticker.PromptViewController`, which
    // is in our example implemented below the LinkSmartSticker. We pass the instance
    // of our sticker so we later know which sticker is used, so a certain PromptViewController
    // could be reused.
    override var prompt: SmartSticker.PromptViewController? {
      LinkSmartStickerViewController(sticker: self)
    }
    // highlight-sticker-prompt

    var textAttributes: [NSAttributedString.Key: Any] {
      [
        .font: UIFont.boldSystemFont(ofSize: fontSize),
        .foregroundColor: textColor
      ]
    }

    init(identifier: String, textColor: UIColor, boxColor: UIColor, iconColor: UIColor) {
      self.textColor = textColor
      self.boxColor = boxColor
      self.iconColor = iconColor

      super.init(identifier: identifier)
    }

    private func linkText(from metadata: [String: String]? = nil) -> String {
      guard let metadata = metadata else { return previewText }
      let url = URL(string: metadata["url"]!)!
      return url.host?.lowercased() ?? previewText
    }

    // highlight-sticker-smart
    // We will implement `size` method here, that will return the size we are
    // requesting to draw sticker on.
    override func size(for metadata: [String: String]? = nil) -> CGSize {
      // First we extract link text from metadata. If metadata is nil, we
      // will return preview text which is "LINK" in our case
      let text = linkText(from: metadata)
      // We calculate text screen size with our helper method.
      let textSize = text.imgly.bounds(textAttributes).size

      // Calculate width, which consists of icon width, padding, and text screen width.
      let stickerWidth = iconSize.width + 8 + textSize.width
      // Calculate height, which consists of icon height, and text screen height.
      let stickerHeight = max(iconSize.height, textSize.height)

      // We return the calculated size which we also add paddding onto.
      return CGRect(x: 0, y: 0, width: stickerWidth + padding.left + padding.right, height: stickerHeight + padding.top + padding.bottom).size
    }

    // We will implement `draw` method here, that will render the sticker in graphic
    // context given by renderer.
    override func draw(with metadata: [String: String]?, context: CGContext, size: CGSize, scale: CGFloat) {
      // We create rectangle of size that is passed to us. We need to make
      // sure, our content is scaled correctly to this size.
      let rect = CGRect(origin: .zero, size: size)

      // Here we extract link text from metadata. If metadata is nil, we
      // will return preview text which is "LINK" in our case
      let linkString = linkText(from: metadata)
      // We calculate text screen size with our helper method.
      let textSize = linkString.imgly.bounds(textAttributes).size

      // We calculate our requested size so we can calculate scaling factor.
      let stickerRect = CGRect(origin: .zero, size: self.size(for: metadata))

      // Calculate icon and text positions
      let iconRect = CGRect(origin: .zero, size: iconSize).offsetBy(dx: padding.left, dy: padding.top)
      let dy = (iconRect.height - textSize.height) / 2 + padding.top
      let textRect = CGRect(origin: .zero, size: textSize).offsetBy(dx: iconRect.maxX + 8, dy: dy)

      // We fit our requested rectangle into the given rectangle
      let fittedRect = stickerRect.imgly.fitted(into: rect, with: .scaleAspectFit)
      // Calculate scale ratio
      let fittedScale = fittedRect.width / stickerRect.width

      // Apply scaling and translation of our context
      context.translateBy(x: fittedRect.minX, y: fittedRect.minY)
      context.scaleBy(x: fittedScale, y: fittedScale)

      // Render background rounded rectangle
      context.setFillColor(boxColor.cgColor)
      context.imgly.addRoundedRect(of: stickerRect.size, cornerRadius: CGSize(width: cornerRadius, height: cornerRadius))
      context.fillPath()

      // Render link icon
      let image = UIImage(systemName: "link")?.withTintColor(iconColor)
      image?.draw(in: iconRect)

      // Render link text
      linkString.imgly.draw(in: textRect, context: context, withAttributes: textAttributes)
    }
    // highlight-sticker-smart
  }

  // highlight-prompt
  /// Custom` UIViewController` that will get presented when a certain smart sticker is selected.
  /// It is used to feed arbitrary data to the sticker. You can customize it in any way, just make sure you
  /// call either `done(metadata: [String: String])` to render the sticker with `metadata` or
  /// `cancel()` to dismiss this `SmartSticker.PromptViewController`.
  ///
  /// In this example we will configure it in a way it will show two buttons for cancelling and applying in the navigation bar,
  /// and a text box below that will be used to enter URL that will be used when rendering `LinkSmartSticker` .
  @objc(PLinkSmartStickerViewController) class LinkSmartStickerViewController: SmartSticker.PromptViewController {

    // MARK: - Properties

    private let linkTextField: UITextField = {
      let textField = UITextField()

      textField.borderStyle = .none
      textField.placeholder = "https://example.com"
      textField.translatesAutoresizingMaskIntoConstraints = false
      return textField
    }()

    // MARK: - View creation

    private func createNavigationBar() -> UINavigationBar {
      let navigationBar = UINavigationBar()
      navigationBar.translatesAutoresizingMaskIntoConstraints = false

      let navigationItem = UINavigationItem(title: "Add Link")
      let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(addLinkTapped))
      let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelTapped))

      navigationItem.rightBarButtonItem = doneItem
      navigationItem.leftBarButtonItem = cancelItem

      navigationBar.setItems([navigationItem], animated: false)
      return navigationBar
    }

    private func createURLLabel() -> UILabel {
      let label = UILabel()

      label.font = UIFont.systemFont(ofSize: 14)
      label.textColor = UIColor.lightGray
      label.text = "URL"

      label.translatesAutoresizingMaskIntoConstraints = false
      return label
    }

    private func setupView() {
      let navigationBar = createNavigationBar()
      let urlLabel = createURLLabel()

      view.addSubview(navigationBar)
      view.addSubview(urlLabel)
      view.addSubview(linkTextField)

      NSLayoutConstraint.activate(
        [
          navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
          navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

          urlLabel.topAnchor.constraint(equalTo: navigationBar.safeAreaLayoutGuide.bottomAnchor, constant: 16),
          urlLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

          linkTextField.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 8),
          linkTextField.leadingAnchor.constraint(equalTo: urlLabel.leadingAnchor)
        ]
      )
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemBackground

      setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
      linkTextField.becomeFirstResponder()
    }

    // MARK: - Actions

    @objc func addLinkTapped() {
      guard var text = linkTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
      if !text.starts(with: "http://"), !text.starts(with: "https://") {
        text = "https://\(text)"
      }

      if URL(string: text) != nil {
        // We call `done` here with desired metadata,
        // that will be passed to `SmartSticker.draw` method
        // when sticker instance is rendered.
        done(metadata: ["url": text])
      }
    }

    @objc func cancelTapped() {
      // In case we don't want to proceed with sticker
      // we selected, calling `cancel` will dismiss this
      // `SmartSticker.PromptViewController`.
      cancel()
    }
  }
}
// highlight-prompt

class PhotoLinkSmartSticker: Example, PhotoEditViewControllerDelegate {

  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Create an asset catalog with default items that we will use to add
    // our smart sticker.
    let assetCatalog = AssetCatalog.defaultItems

    // For this example we will create a smart sticker with multiple
    // variations so we will define few colors for background box, text
    // and icon color.
    // highlight-variations
    let boxColors = [
      UIColor(red: 246, green: 246, blue: 246).withAlphaComponent(0.55),
      UIColor(red: 246, green: 246, blue: 246),
      UIColor(red: 51, green: 51, blue: 55).withAlphaComponent(0.55),
      UIColor(red: 51, green: 51, blue: 55)
    ]

    let textColors = [
      UIColor(red: 51, green: 51, blue: 55),
      UIColor(red: 51, green: 51, blue: 55),
      UIColor(red: 246, green: 246, blue: 246),
      UIColor(red: 246, green: 246, blue: 246)
    ]

    let iconColors = [
      UIColor(red: 51, green: 51, blue: 55),
      UIColor(red: 38, green: 119, blue: 253),
      UIColor(red: 246, green: 246, blue: 246),
      UIColor(red: 255, green: 92, blue: 0)
    ]

    // Create 4 instances of LinkSmartSticker that is defined below in
    // the code.
    let multiLinkStickers = (0 ..< 4).map {
      LinkSmartSticker(identifier: "imgly_link_smart_sticker_\($0 + 1)", textColor: textColors[$0], boxColor: boxColors[$0], iconColor: iconColors[$0])
    }

    // When we have stickers generated we will add them to a MultiImageSticker
    // that will allow us to change between variations with tapping on the
    // sticker on the canvas.
    let multiLinkSticker = MultiImageSticker(identifier: "imgly_link_smart_sticker", imageURL: nil, stickers: multiLinkStickers)
    // highlight-variations

    // For this example we will create a sticker category that will only hold
    // our Multi LinkSmartSticker.
    // highlight-stickers
    let stickerCategory = StickerCategory(identifier: "smart_stickers", title: "Smart Stickers", imageURL: Bundle.imgly.resourceBundle.url(forResource: "imgly_sticker_shapes_badge_28", withExtension: "png")!, stickers: [multiLinkSticker])

    assetCatalog.stickers = [stickerCategory]
    // highlight-stickers

    // Create a `Configuration` object.
    // highlight-config
    let configuration = Configuration { builder in
      // Assign asset catalog  we defined before to the configuration builder.
      builder.assetCatalog = assetCatalog
    }
    // highlight-config

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

    // highlight-query-metadata
    // Here we can query what URLs were entered by the user.
    let stickerLinks = result.task.model.spriteModels.compactMap { ($0 as? StickerSpriteModel)?.metadata?["url"] }
    print(stickerLinks)
    // highlight-query-metadata

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

/// Helper extension to reduce boilerplate code above.
extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
  }
}
