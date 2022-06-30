import UIKit
import VideoEditorSDK

class VideoCompositionConfigurationSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Identifiers of video clips in the app bundle.
    let miscVideoClipIdentifiers = [
      "delivery",
      "notes"
    ]
    let peopleVideoClipIdentifiers = [
      "dj",
      "rollerskates"
    ]

    // Create new video clip categories with custom video clips from
    // the app bundle.
    let miscClips = miscVideoClipIdentifiers.map { VideoClip(identifier: $0, videoURL: Bundle.main.url(forResource: $0, withExtension: ".mp4")!) }
    let peopleClips = peopleVideoClipIdentifiers.map { VideoClip(identifier: $0, videoURL: Bundle.main.url(forResource: $0, withExtension: ".mp4")!) }

    let miscVideoClipCategory = VideoClipCategory(title: "Misc", imageURL: nil, videoClips: miscClips)
    let peopleVideoClipCategory = VideoClipCategory(title: "People", imageURL: nil, videoClips: peopleClips)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // Add the custom video clips to the asset catalog.
      // highlight-clips
      builder.assetCatalog.videoClips = [miscVideoClipCategory, peopleVideoClipCategory]
      // highlight-clips

      // Configure the `CompositionToolController` that lets the user edit
      // the video composition.
      // highlight-actions
      builder.configureCompositionToolController { options in
        // By default editor presents an image picker for adding video clips
        // to the composition. For this example, the editor should present the
        // `VideoClipToolController` which lets the user select video clips
        // that have been added to the `AssetCatalog`.
        options.videoClipLibraryMode = .predefined
      }
      // highlight-actions

      // Configure the `VideoClipToolController` that lets the user
      // add videos to the video composition.
      builder.configureVideoClipToolController { options in
        // By default the editor selects the first video clip category
        // when opening the selection tool. For this example the editor
        // will select the second category.
        // highlight-category
        options.defaultVideoClipCategoryIndex = 1
        // highlight-category

        // By default the user is allowed to add personal video clips
        // from the device. For this example the user is only allowed
        // to add video clips that are predefined in the editor configuration.
        // highlight-personal
        options.personalVideoClipsEnabled = false
        // highlight-personal
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
