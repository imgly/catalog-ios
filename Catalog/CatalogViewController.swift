import ImglyKit
import UIKit

class CatalogViewController: UIViewController {

  // MARK: - Examples

  private lazy var examples: [ExampleItem] = {
    [
      ExampleItem(title: "Getting Started", examples: [
        ExampleItem(title: "Show Editor UIKit", subtitle: "Presents the photo editor modally using UIKit.", products: [.pesdk], swiftExample: ShowPhotoEditorUIKitSwift.self, objCExample: ShowPhotoEditorUIKitObjC.self),
        ExampleItem(title: "Show Editor SwiftUI", subtitle: "Presents the photo editor modally using SwiftUI.", products: [.pesdk], swiftExample: ShowPhotoEditorSwiftUISwift.self, objCExample: nil),
        ExampleItem(title: "Show Editor UIKit", subtitle: "Presents the video editor modally using UIKit.", products: [.vesdk], swiftExample: ShowVideoEditorUIKitSwift.self, objCExample: ShowVideoEditorUIKitObjC.self),
        ExampleItem(title: "Show Editor SwiftUI", subtitle: "Presents the video editor modally using SwiftUI.", products: [.vesdk], swiftExample: ShowVideoEditorSwiftUISwift.self, objCExample: nil),
        ExampleItem(title: "Embed Editor UIKit", subtitle: "Presents the photo editor embedded in a UINavigationController using UIKit.", products: [.pesdk], swiftExample: EmbedPhotoEditorUIKitSwift.self, objCExample: EmbedPhotoEditorUIKitObjC.self),
        ExampleItem(title: "Embed Editor SwiftUI", subtitle: "Presents the photo editor embedded in a NavigationView using SwiftUI.", products: [.pesdk], swiftExample: EmbedPhotoEditorSwiftUISwift.self, objCExample: nil),
        ExampleItem(title: "Embed Editor UIKit", subtitle: "Presents the video editor embedded in a UINavigationController using UIKit.", products: [.vesdk], swiftExample: EmbedVideoEditorUIKitSwift.self, objCExample: EmbedVideoEditorUIKitObjC.self),
        ExampleItem(title: "Embed Editor SwiftUI", subtitle: "Presents the video editor embedded in a NavigationView using SwiftUI.", products: [.vesdk], swiftExample: EmbedVideoEditorSwiftUISwift.self, objCExample: nil),
        ExampleItem(title: "Show Camera UIKit", subtitle: "Presents the camera view controller modally using UIKit.", products: [.pesdk], swiftExample: ShowPhotoCameraUIKitSwift.self, objCExample: ShowPhotoCameraUIKitObjC.self),
        ExampleItem(title: "Show Camera SwiftUI", subtitle: "Presents the camera view controller modally using SwiftUI.", products: [.pesdk], swiftExample: ShowPhotoCameraSwiftUISwift.self, objCExample: nil),
        ExampleItem(title: "Show Camera UIKit", subtitle: "Presents the camera view controller modally using UIKit.", products: [.vesdk], swiftExample: ShowVideoCameraUIKitSwift.self, objCExample: ShowVideoCameraUIKitObjC.self),
        ExampleItem(title: "Show Camera SwiftUI", subtitle: "Presents the camera view controller modally using SwiftUI.", products: [.vesdk], swiftExample: ShowVideoCameraSwiftUISwift.self, objCExample: nil),
        ExampleItem(title: "Show basic configuration", subtitle: "Presents the camera modally using a basic configuration example", products: [.pesdk, .vesdk], swiftExample: ConfigurationExampleSwift.self, objCExample: ConfigurationExampleObjC.self)
      ]),
      ExampleItem(title: "Opening Assets", examples: [
        ExampleItem(title: "From Camera Roll", subtitle: "Loads a video from camera roll and presents the video editor.", products: [.vesdk], swiftExample: OpenVideoFromCameraRollSwift.self, objCExample: OpenVideoFromCameraRollObjC.self),
        ExampleItem(title: "From App Bundle", subtitle: "Loads a video from the app bundle and presents the video editor.", products: [.vesdk], swiftExample: OpenVideoFromAppBundleSwift.self, objCExample: OpenVideoFromAppBundleObjC.self),
        ExampleItem(title: "From Remote URL", subtitle: "Loads a video from an remote URL and presents the video editor.", products: [.vesdk], swiftExample: OpenVideoFromRemoteURLSwift.self, objCExample: OpenVideoFromRemoteURLObjC.self),
        ExampleItem(title: "From Multiple Video Clips", subtitle: "Loads multiple video clips and presents the video editor.", products: [.vesdk], swiftExample: OpenVideoFromMultipleVideoClipsSwift.self, objCExample: OpenVideoFromMultipleVideoClipsObjC.self),
        ExampleItem(title: "From Camera Roll", subtitle: "Loads a photo from camera roll and presents the photo editor.", products: [.pesdk], swiftExample: OpenPhotoFromCameraRollSwift.self, objCExample: OpenPhotoFromCameraRollObjC.self),
        ExampleItem(title: "From App Bundle", subtitle: "Loads a photo from the app bundle and presents the photo editor.", products: [.pesdk], swiftExample: OpenPhotoFromAppBundleSwift.self, objCExample: OpenPhotoFromAppBundleObjC.self),
        ExampleItem(title: "From Remote URL", subtitle: "Loads a photo from an remote URL and presents the photo editor.", products: [.pesdk], swiftExample: OpenPhotoFromRemoteURLSwift.self, objCExample: OpenPhotoFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Saving Assets", examples: [
        ExampleItem(title: "To Camera Roll", subtitle: "Presents the video editor and saves the exported video to the camera roll.", products: [.vesdk], swiftExample: SaveVideoToCameraRollSwift.self, objCExample: SaveVideoToCameraRollObjC.self),
        ExampleItem(title: "To Remote URL", subtitle: "Presents the video editor and saves the exported video to a remote URL.", products: [.vesdk], swiftExample: SaveVideoToRemoteURLSwift.self, objCExample: SaveVideoToRemoteURLObjC.self),
        ExampleItem(title: "To Filesystem", subtitle: "Presents the video editor and saves the exported video to the filesystem.", products: [.vesdk], swiftExample: SaveVideoToFilesystemSwift.self, objCExample: SaveVideoToFilesystemObjC.self),
        ExampleItem(title: "To Data", subtitle: "Presents the video editor and saves the exported video in a Data object.", products: [.vesdk], swiftExample: SaveVideoToDataSwift.self, objCExample: SaveVideoToDataObjC.self),
        ExampleItem(title: "To Base64", subtitle: "Presents the video editor and saves the exported video to a Base64 encoded String.", products: [.vesdk], swiftExample: SaveVideoToBase64Swift.self, objCExample: SaveVideoToBase64ObjC.self),
        ExampleItem(title: "To Camera Roll", subtitle: "Presents the photo editor and saves the exported photo to the camera roll.", products: [.pesdk], swiftExample: SavePhotoToCameraRollSwift.self, objCExample: SavePhotoToCameraRollObjC.self),
        ExampleItem(title: "To Remote URL", subtitle: "Presents the photo editor and saves the exported photo to a remote URL.", products: [.pesdk], swiftExample: SavePhotoToRemoteURLSwift.self, objCExample: SavePhotoToRemoteURLObjC.self),
        ExampleItem(title: "To Filesystem", subtitle: "Presents the photo editor and saves the exported photo to the filesystem.", products: [.pesdk], swiftExample: SavePhotoToFilesystemSwift.self, objCExample: SavePhotoToFilesystemObjC.self),
        ExampleItem(title: "To Data", subtitle: "Presents the photo editor and saves the exported photo in a Data object.", products: [.pesdk], swiftExample: SavePhotoToDataSwift.self, objCExample: SavePhotoToDataObjC.self),
        ExampleItem(title: "To Base64", subtitle: "Presents the photo editor and saves the exported photo to a Base64 encoded String.", products: [.pesdk], swiftExample: SavePhotoToBase64Swift.self, objCExample: SavePhotoToBase64ObjC.self)
      ]),
      ExampleItem(title: "Saving State", examples: [
        ExampleItem(title: "Serialization", subtitle: "Presents a photo editor, serializes all edits and prints the output to the debugging console.", products: [.pesdk], swiftExample: PhotoSerializationSwift.self, objCExample: PhotoSerializationObjC.self),
        ExampleItem(title: "Serialization", subtitle: "Presents a video editor, serializes all edits and prints the output to the debugging console.", products: [.vesdk], swiftExample: VideoSerializationSwift.self, objCExample: VideoSerializationObjC.self)
      ]),
      ExampleItem(title: "Restoring State", examples: [
        ExampleItem(title: "Deserialization", subtitle: "Loads a serialized JSON file from the app bundle and presents a photo editor with state restored.", products: [.pesdk], swiftExample: PhotoDeserializationSwift.self, objCExample: PhotoDeserializationObjC.self),
        ExampleItem(title: "Deserialization", subtitle: "Loads a serialized JSON file from the app bundle and presents a photo editor with state restored.", products: [.vesdk], swiftExample: VideoDeserializationSwift.self, objCExample: VideoDeserializationObjC.self)
      ]),
      ExampleItem(title: "User Interface Customization", examples: [
        ExampleItem(title: "Theming", subtitle: "Presents a photo editor with a customized Theme.", products: [.pesdk], swiftExample: PhotoThemingSwift.self, objCExample: PhotoThemingObjC.self),
        ExampleItem(title: "Theming", subtitle: "Presents a video editor with a customized Theme.", products: [.vesdk], swiftExample: VideoThemingSwift.self, objCExample: VideoThemingObjC.self),
        ExampleItem(title: "Customize Icons", subtitle: "Presents a photo editor with customized icons.", products: [.pesdk], swiftExample: PhotoCustomizeIconsSwift.self, objCExample: PhotoCustomizeIconsObjC.self),
        ExampleItem(title: "Customize Icons", subtitle: "Presents a video editor with customized icons.", products: [.vesdk], swiftExample: VideoCustomizeIconsSwift.self, objCExample: VideoCustomizeIconsObjC.self),
        ExampleItem(title: "Localization", subtitle: "Presents a photo editor with customized localizations.", products: [.pesdk], swiftExample: PhotoLocalizationSwift.self, objCExample: PhotoLocalizationObjC.self),
        ExampleItem(title: "Localization", subtitle: "Presents a video editor with customized localizations.", products: [.vesdk], swiftExample: VideoLocalizationSwift.self, objCExample: VideoLocalizationObjC.self)
      ]),
      ExampleItem(title: "Camera Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a camera modally using a custom configuration.", products: [.pesdk], swiftExample: PhotoCameraConfigurationSwift.self, objCExample: PhotoCameraConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a camera modally using a custom configuration.", products: [.vesdk], swiftExample: VideoCameraConfigurationSwift.self, objCExample: VideoCameraConfigurationObjC.self)
      ]),
      ExampleItem(title: "Editor Configuration", examples: [
        ExampleItem(title: "Customize Menu Items", subtitle: "Presents a photo editor with customized menu items modally.", products: [.pesdk], swiftExample: PhotoCustomizeMenuItemsSwift.self, objCExample: PhotoCustomizeMenuItemsObjC.self),
        ExampleItem(title: "Customize Menu Items", subtitle: "Presents a video editor with customized menu items modally.", products: [.vesdk], swiftExample: VideoCustomizeMenuItemsSwift.self, objCExample: VideoCustomizeMenuItemsObjC.self),
        ExampleItem(title: "Single Tool Use", subtitle: "Presents a photo editor in a single tool mode where main menu is skipped", products: [.pesdk], swiftExample: PhotoCustomizeSingleToolUseSwift.self, objCExample: PhotoCustomizeSingleToolUseObjC.self),
        ExampleItem(title: "Single Tool Use", subtitle: "Presents a video editor in a single tool mode where main menu is skipped", products: [.vesdk], swiftExample: VideoCustomizeSingleToolUseSwift.self, objCExample: VideoCustomizeSingleToolUseObjC.self),
        ExampleItem(title: "Add Custom Tool", subtitle: "Presents a photo editor with a custom tool modally.", products: [.pesdk], swiftExample: PhotoAddCustomToolSwift.self, objCExample: nil),
        ExampleItem(title: "Add Custom Tool", subtitle: "Presents a video editor with a custom tool modally.", products: [.vesdk], swiftExample: VideoAddCustomToolSwift.self, objCExample: nil),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom configuration.", products: [.pesdk], swiftExample: PhotoEditorConfigurationSwift.self, objCExample: PhotoEditorConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom configuration.", products: [.vesdk], swiftExample: VideoEditorConfigurationSwift.self, objCExample: VideoEditorConfigurationObjC.self),
        ExampleItem(title: "Customize Snapping", subtitle: "Present a photo editor modally using a custom snapping configuration.", products: [.pesdk], swiftExample: PhotoSnapping.self, objCExample: PhotoSnappingObjC.self),
        ExampleItem(title: "Customize Snapping", subtitle: "Present a photo editor modally using a custom snapping configuration.", products: [.vesdk], swiftExample: VideoSnapping.self, objCExample: VideoSnappingObjC.self)
      ]),
      ExampleItem(title: "Video Composition Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom composition tool configuration.", products: [.vesdk], swiftExample: VideoCompositionConfigurationSwift.self, objCExample: VideoCompositionConfigurationObjC.self),
        ExampleItem(title: "Enforce video duration", subtitle: "Presents a video editor modally using a custom composition tool configuration to enforce a minimum and maximum video length.", products: [.vesdk], swiftExample: CompositionEnforceDurationSwift.self, objCExample: CompositionEnforceDurationObjC.self)
      ]),
      ExampleItem(title: "Trim Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom trim tool configuration.", products: [.vesdk], swiftExample: TrimConfigurationSwift.self, objCExample: TrimConfigurationObjC.self),
        ExampleItem(title: "Enforce video duration", subtitle: "Presents a video editor modally using a custom trim tool configuration to enforce a minimum and maximum video length.", products: [.vesdk], swiftExample: TrimEnforceDurationSwift.self, objCExample: TrimEnforceDurationObjC.self)
      ]),
      ExampleItem(title: "Audio Overlay Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom audio overlay tool configuration.", products: [.vesdk], swiftExample: AudioOverlayConfigurationSwift.self, objCExample: AudioOverlayConfigurationObjC.self),
        ExampleItem(title: "Add audio overlay from app bundle", subtitle: "Loads audio overlays from the app bundle and presents a video editor modally.", products: [.vesdk], swiftExample: AddAudioOverlaysFromAppBundleSwift.self, objCExample: AddAudioOverlaysFromAppBundleObjC.self),
        ExampleItem(title: "Add audio overlay from remote URL", subtitle: "Loads audio overlays from a remote URL and presents a video editor modally.", products: [.vesdk], swiftExample: AddAudioOverlaysFromRemoteURLSwift.self, objCExample: AddAudioOverlaysFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Transform Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom transform tool configuration.", products: [.pesdk], swiftExample: PhotoTransformConfigurationSwift.self, objCExample: PhotoTransformConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom transform tool configuration.", products: [.vesdk], swiftExample: VideoTransformConfigurationSwift.self, objCExample: VideoTransformConfigurationObjC.self)
      ]),
      ExampleItem(title: "Filter Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom filter tool configuration.", products: [.pesdk], swiftExample: PhotoFiltersConfigurationSwift.self, objCExample: PhotoFiltersConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom filter tool configuration.", products: [.vesdk], swiftExample: VideoFiltersConfigurationSwift.self, objCExample: VideoFiltersConfigurationObjC.self),
        ExampleItem(title: "Add filter from app bundle", subtitle: "Loads filters from the app bundle and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddFiltersFromAppBundleSwift.self, objCExample: PhotoAddFiltersFromAppBundleObjC.self),
        ExampleItem(title: "Add filter from app bundle", subtitle: "Loads filters from the app bundle and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddFiltersFromAppBundleSwift.self, objCExample: VideoAddFiltersFromAppBundleObjC.self),
        ExampleItem(title: "Add filter from remote URL", subtitle: "Loads filters from a remote URL and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddFiltersFromRemoteURLSwift.self, objCExample: PhotoAddFiltersFromRemoteURLObjC.self),
        ExampleItem(title: "Add filter from remote URL", subtitle: "Loads filters from a remote URL and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddFiltersFromRemoteURLSwift.self, objCExample: VideoAddFiltersFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Adjustment Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom adjustment tool configuration.", products: [.pesdk], swiftExample: PhotoAdjustmentsConfigurationSwift.self, objCExample: PhotoAdjustmentsConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom adjustment tool configuration.", products: [.vesdk], swiftExample: VideoAdjustmentsConfigurationSwift.self, objCExample: VideoAdjustmentsConfigurationObjC.self)
      ]),
      ExampleItem(title: "Focus Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom focus tool configuration.", products: [.pesdk], swiftExample: PhotoFocusConfigurationSwift.self, objCExample: PhotoFocusConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom focus tool configuration.", products: [.vesdk], swiftExample: VideoFocusConfigurationSwift.self, objCExample: VideoFocusConfigurationObjC.self)
      ]),
      ExampleItem(title: "Sticker Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom sticker tool configuration.", products: [.pesdk], swiftExample: PhotoStickersConfigurationSwift.self, objCExample: PhotoStickersConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom sticker tool configuration.", products: [.vesdk], swiftExample: VideoStickersConfigurationSwift.self, objCExample: VideoStickersConfigurationObjC.self),
        ExampleItem(title: "Link Smart Sticker", subtitle: "Presents a photo editor modally using a custom sticker tool configuration.", products: [.pesdk], swiftExample: PhotoLinkSmartSticker.self, objCExample: PhotoLinkSmartStickerObjC.self),
        ExampleItem(title: "Link Smart Sticker", subtitle: "Presents a photo editor modally using a custom sticker tool configuration.", products: [.vesdk], swiftExample: VideoLinkSmartSticker.self, objCExample: VideoLinkSmartStickerObjC.self),
        ExampleItem(title: "Add sticker from app bundle", subtitle: "Loads stickers from the app bundle and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddStickersFromAppBundleSwift.self, objCExample: PhotoAddStickersFromAppBundleObjC.self),
        ExampleItem(title: "Add sticker from app bundle", subtitle: "Loads stickers from the app bundle and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddStickersFromAppBundleSwift.self, objCExample: VideoAddStickersFromAppBundleObjC.self),
        ExampleItem(title: "Add sticker from remote URL", subtitle: "Loads stickers from a remote URL and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddStickersFromRemoteURLSwift.self, objCExample: PhotoAddStickersFromRemoteURLObjC.self),
        ExampleItem(title: "Add sticker from remote URL", subtitle: "Loads stickers from a remote URL and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddStickersFromRemoteURLSwift.self, objCExample: VideoAddStickersFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Text Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom text tool configuration.", products: [.pesdk], swiftExample: PhotoTextConfigurationSwift.self, objCExample: PhotoTextConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom text tool configuration.", products: [.vesdk], swiftExample: VideoTextConfigurationSwift.self, objCExample: VideoTextConfigurationObjC.self),
        ExampleItem(title: "Add font from app bundle", subtitle: "Loads fonts from the app bundle and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddFontsFromAppBundleSwift.self, objCExample: PhotoAddFontsFromAppBundleObjC.self),
        ExampleItem(title: "Add font from app bundle", subtitle: "Loads fonts from the app bundle and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddFontsFromAppBundleSwift.self, objCExample: VideoAddFontsFromAppBundleObjC.self),
        ExampleItem(title: "Add font from remote URL", subtitle: "Loads fonts from a remote URL and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddFontsFromRemoteURLSwift.self, objCExample: PhotoAddFontsFromRemoteURLObjC.self),
        ExampleItem(title: "Add font from remote URL", subtitle: "Loads fonts from a remote URL and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddFontsFromRemoteURLSwift.self, objCExample: VideoAddFontsFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Text Design Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom text design tool configuration.", products: [.pesdk], swiftExample: PhotoTextDesignConfigurationSwift.self, objCExample: PhotoTextDesignConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom text design tool configuration.", products: [.vesdk], swiftExample: VideoTextDesignConfigurationSwift.self, objCExample: VideoTextDesignConfigurationObjC.self)
      ]),
      ExampleItem(title: "Overlay Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom overlay tool configuration.", products: [.pesdk], swiftExample: PhotoOverlaysConfigurationSwift.self, objCExample: PhotoOverlaysConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom overlay tool configuration.", products: [.vesdk], swiftExample: VideoOverlaysConfigurationSwift.self, objCExample: VideoOverlaysConfigurationObjC.self),
        ExampleItem(title: "Add overlay from app bundle", subtitle: "Loads overlays from the app bundle and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddOverlaysFromAppBundleSwift.self, objCExample: PhotoAddOverlaysFromAppBundleObjC.self),
        ExampleItem(title: "Add overlay from app bundle", subtitle: "Loads overlays from the app bundle and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddOverlaysFromAppBundleSwift.self, objCExample: VideoAddOverlaysFromAppBundleObjC.self),
        ExampleItem(title: "Add overlay from remote URL", subtitle: "Loads overlays from a remote URL and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddOverlaysFromRemoteURLSwift.self, objCExample: PhotoAddOverlaysFromRemoteURLObjC.self),
        ExampleItem(title: "Add overlay from remote URL", subtitle: "Loads overlays from a remote URL and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddOverlaysFromRemoteURLSwift.self, objCExample: VideoAddOverlaysFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Frame Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom frame tool configuration.", products: [.pesdk], swiftExample: PhotoFramesConfigurationSwift.self, objCExample: PhotoFramesConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom frame tool configuration.", products: [.vesdk], swiftExample: VideoFramesConfigurationSwift.self, objCExample: VideoFramesConfigurationObjC.self),
        ExampleItem(title: "Add frame from app bundle", subtitle: "Loads frames from the app bundle and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddFramesFromAppBundleSwift.self, objCExample: PhotoAddFramesFromAppBundleObjC.self),
        ExampleItem(title: "Add frame from app bundle", subtitle: "Loads frames from the app bundle and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddFramesFromAppBundleSwift.self, objCExample: VideoAddFramesFromAppBundleObjC.self),
        ExampleItem(title: "Add frame from remote URL", subtitle: "Loads frames from a remote URL and presents a photo editor modally.", products: [.pesdk], swiftExample: PhotoAddFramesFromRemoteURLSwift.self, objCExample: PhotoAddFramesFromRemoteURLObjC.self),
        ExampleItem(title: "Add frame from remote URL", subtitle: "Loads frames from a remote URL and presents a video editor modally.", products: [.vesdk], swiftExample: VideoAddFramesFromRemoteURLSwift.self, objCExample: VideoAddFramesFromRemoteURLObjC.self)
      ]),
      ExampleItem(title: "Brush Configuration", examples: [
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a photo editor modally using a custom brush tool configuration.", products: [.pesdk], swiftExample: PhotoBrushConfigurationSwift.self, objCExample: PhotoBrushConfigurationObjC.self),
        ExampleItem(title: "Custom Configuration", subtitle: "Presents a video editor modally using a custom brush tool configuration.", products: [.vesdk], swiftExample: VideoBrushConfigurationSwift.self, objCExample: VideoBrushConfigurationObjC.self)
      ]),
      ExampleItem(title: "Solutions", examples: [
        ExampleItem(title: "Annotation", subtitle: "Presents a photo editor modally that's configured to work for an annotation use case.", products: [.pesdk], swiftExample: PhotoAnnotationSolutionSwift.self, objCExample: PhotoAnnotationSolutionObjC.self),
        ExampleItem(title: "Annotation", subtitle: "Presents a video editor modally that's configured to work for an annotation use case.", products: [.vesdk], swiftExample: VideoAnnotationSolutionSwift.self, objCExample: VideoAnnotationSolutionObjC.self)
      ])
    ]
  }()

  // MARK: - Helpers

  private enum Language: String {
    case swift = "Swift"
    case objectiveC = "Objective-C"
  }

  // MARK: - Properties

  private var selectedLanguage = Language.swift

  // Keep a reference to the last invoked example so it doesn't get destroyed after invocation and can still act as a delegate for controllers.
  // Make sure to not introduce any reference cycles because of this when implementing examples.
  private var activeExample: Example?

  private lazy var collectionViewDataSource: UICollectionViewDiffableDataSource<Int, ExampleItem> = {
    let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ExampleItem> { cell, _, item in
      var content = cell.defaultContentConfiguration()
      content.text = item.title
      cell.accessories = [.outlineDisclosure()]
      cell.contentConfiguration = content
    }

    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ExampleItem> { cell, _, item in
      var content = cell.defaultContentConfiguration()
      content.text = item.title
      content.secondaryText = item.subtitle
      cell.accessories = [.disclosureIndicator()]
      cell.contentConfiguration = content
    }

    return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
      if indexPath.item == 0 {
        return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
      } else {
        return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
      }
    }
  }()

  private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
    var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    config.headerMode = .firstItemInSection

    return UICollectionViewCompositionalLayout.list(using: config)
  }()

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
    return collectionView
  }()

  private let segmentedControl = UISegmentedControl()

  private var selectedProduct: Product {
    Product.allCases[segmentedControl.selectedSegmentIndex]
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    installSegmentedControl()
    installCollectionView()
    loadInitialData()
    updateBarButtonItem()
  }

  // MARK: - View Setup

  private func installSegmentedControl() {
    for (index, product) in Product.allCases.enumerated() {
      segmentedControl.insertSegment(withTitle: product.rawValue, at: index, animated: false)
    }

    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)

    navigationItem.titleView = segmentedControl
  }

  private func installCollectionView() {
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.delegate = self
    collectionView.dataSource = collectionViewDataSource
    view.addSubview(collectionView)
  }

  private func updateBarButtonItem() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: selectedLanguage.rawValue, style: .plain, target: self, action: #selector(changeLanguage))
  }

  // MARK: - Data Handling

  private func loadInitialData() {
    let sections = Array(0 ..< examples.count)
    var snapshot = NSDiffableDataSourceSnapshot<Int, ExampleItem>()
    snapshot.appendSections(sections)
    collectionViewDataSource.apply(snapshot, animatingDifferences: false)

    for section in sections {
      let exampleCategory = examples[section]
      var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ExampleItem>()
      sectionSnapshot.append([exampleCategory])
      sectionSnapshot.append(exampleCategory.examples.filter { example in
        if !example.products.contains(selectedProduct) {
          return false
        }

        switch selectedLanguage {
        case .swift:
          return example.swiftExample != nil
        case .objectiveC:
          return example.objCExample != nil
        }
      }, to: exampleCategory)
      sectionSnapshot.expand([exampleCategory])
      collectionViewDataSource.apply(sectionSnapshot, to: section, animatingDifferences: false)
    }
  }

  private func updateData(animated: Bool) {
    let snapshot = collectionViewDataSource.snapshot()
    let sections = Array(0 ..< snapshot.numberOfSections)

    for section in sections {
      let exampleCategory = examples[section]

      var updatedSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ExampleItem>()
      updatedSectionSnapshot.append(exampleCategory.examples.filter { example in
        if !example.products.contains(selectedProduct) {
          return false
        }

        switch selectedLanguage {
        case .swift:
          return example.swiftExample != nil
        case .objectiveC:
          return example.objCExample != nil
        }
      })

      var sectionSnapshot = collectionViewDataSource.snapshot(for: section)
      sectionSnapshot.replace(childrenOf: exampleCategory, using: updatedSectionSnapshot)
      collectionViewDataSource.apply(sectionSnapshot, to: section, animatingDifferences: animated)
    }
  }

  // MARK: - Actions

  @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
    updateData(animated: true)
  }

  @objc private func changeLanguage() {
    switch selectedLanguage {
    case .swift:
      selectedLanguage = .objectiveC
    case .objectiveC:
      selectedLanguage = .swift
    }

    updateData(animated: true)
    updateBarButtonItem()
  }

  // MARK: - Example Handling

  /// This will restore any defaults prior to invoking an example.
  private func restoreDefaults() {
    // Reset class replacements
    IMGLY.resetClassReplacements()

    // Reset `IMGLY` globals
    IMGLY.reset()
  }
}

extension CatalogViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let example = collectionViewDataSource.itemIdentifier(for: indexPath) else { return }

    collectionView.deselectItem(at: indexPath, animated: true)

    let exampleClass: Example.Type?

    switch selectedLanguage {
    case .swift:
      exampleClass = example.swiftExample
    case .objectiveC:
      exampleClass = example.objCExample
    }

    if let exampleClass = exampleClass {
      // Restore editor defaults prior to example invocation
      restoreDefaults()

      // Invoke example
      let example = exampleClass.init()
      example.presentingViewController = self
      example.invokeExample()
      activeExample = example
    }
  }
}
