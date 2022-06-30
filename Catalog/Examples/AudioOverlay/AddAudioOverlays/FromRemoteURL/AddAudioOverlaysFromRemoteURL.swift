import UIKit
import VideoEditorSDK

class AddAudioOverlaysFromRemoteURLSwift: Example, VideoEditViewControllerDelegate {
  // The local locations of the downloaded remote resources.
  private var downloadLocations = [String: URL]()

  // Although the editor supports adding assets with remote URLs, we highly recommend
  // that you manage the download of remote resources yourself, since this
  // gives you more control over the whole process. After successfully downloading
  // the files you should pass the local URLs to the asset catalog of the configuration.
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Identifiers of remote audio clips.
    // highlight-start-download
    let elsewhereAudioClipIdentifiers = [
      "elsewhere",
      "trapped_in_the_upside_down"
    ]
    let otherAudioClipIdentifiers = [
      "dance_harder",
      "far_from_home"
    ]

    // All available identifiers of the audio clips.
    let audioClipIdentifiers = elsewhereAudioClipIdentifiers + otherAudioClipIdentifiers

    // Download each of the remote resources.
    audioClipIdentifiers.forEach { identifier in
      guard let remoteURL = URL(string: "https://img.ly/static/example-assets/\(identifier).mp3") else {
        fatalError("Unable to parse URL.")
      }
      let downloadTask = URLSession.shared.downloadTask(with: remoteURL) { downloadURL, _, error in
        if let error = error {
          fatalError("There was an error downloading the file: \(error)")
        }

        guard let downloadURL = downloadURL else {
          return
        }

        // File was downloaded successfully. Saving it in the temporary directory.
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let localURL = temporaryDirectoryURL.appendingPathComponent("\(identifier).mp3")

        if FileManager.default.fileExists(atPath: localURL.path) {
          // Remove the file at the destination if it already exists
          try? FileManager.default.removeItem(at: localURL)
        }
        try? FileManager.default.moveItem(at: downloadURL, to: localURL)
        // highlight-start-download

        // Dispatch to the main queue for any UI work
        // and to prevent race conditions.
        // highlight-main-queue
        DispatchQueue.main.async {
          self.downloadLocations[identifier] = localURL
          // highlight-main-queue

          // If all resources have been downloaded the editor can be started.
          // highlight-load-clips
          if self.downloadLocations.count == audioClipIdentifiers.count {
            // Create new audio clip categories with custom audio clips from
            // the downloaded resources.
            let elsewhereClipsLocations = self.downloadLocations.filter { elsewhereAudioClipIdentifiers.contains($0.key) }
            let otherClipsLocations = self.downloadLocations.filter { otherAudioClipIdentifiers.contains($0.key) }

            let elsewhereClips = elsewhereClipsLocations.map { AudioClip(identifier: $0.key, audioURL: $0.value) }
            let otherClips = otherClipsLocations.map { AudioClip(identifier: $0.key, audioURL: $0.value) }
            // highlight-load-clips

            // highlight-categories
            let elsewhereAudioClipCategory = AudioClipCategory(title: "Elsewhere", imageURL: nil, audioClips: elsewhereClips)
            let otherAudioClipCategory = AudioClipCategory(title: "Other", imageURL: nil, audioClips: otherClips)
            // highlight-categories

            // Create a `Configuration` object.
            // highlight-configure
            let configuration = Configuration { builder in
              // Add the custom audio clips to the asset catalog.
              builder.assetCatalog.audioClips = [elsewhereAudioClipCategory, otherAudioClipCategory]
            }
            // highlight-configure

            // Create the video editor. Make this class the delegate of it to handle export and cancelation.
            let videoEditViewController = VideoEditViewController(videoAsset: video, configuration: configuration)
            videoEditViewController.delegate = self

            // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
            self.presentingViewController?.view.isUserInteractionEnabled = true

            // Present the video editor.
            videoEditViewController.modalPresentationStyle = .fullScreen
            self.presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
          }
        }
      }

      // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
      self.presentingViewController?.view.isUserInteractionEnabled = false

      // Start the file download
      downloadTask.resume()
    }
  }

  // Removes the previously downloaded resources.
  private func removeResources() {
    for location in downloadLocations.values {
      try? FileManager.default.removeItem(at: location)
    }
    downloadLocations.removeAll()
  }

  // MARK: - VideoEditViewControllerDelegate

  func videoEditViewControllerShouldStart(_ videoEditViewController: VideoEditViewController, task: VideoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func videoEditViewControllerDidFinish(_ videoEditViewController: VideoEditViewController, result: VideoEditorResult) {
    // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: {
      self.removeResources()
    })
  }

  func videoEditViewControllerDidFail(_ videoEditViewController: VideoEditViewController, error: VideoEditorError) {
    // There was an error generating the video.
    print(error.localizedDescription)
    // Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: {
      self.removeResources()
    })
  }

  func videoEditViewControllerDidCancel(_ videoEditViewController: VideoEditViewController) {
    // The user tapped on the cancel button within the editor. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: {
      self.removeResources()
    })
  }
}
