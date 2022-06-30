import UIKit
import VideoEditorSDK

class VideoAddFontsFromRemoteURLSwift: Example, VideoEditViewControllerDelegate {
  // Save a reference to the downloaded file to remove it when done.
  private var localURL: URL?

  // Although the editor supports adding assets with remote URLs, we highly recommend
  // that you manage the download of remote resources yourself, since this
  // gives you more control over the whole process. After successfully downloading
  // the files you should pass the local URLs to the asset catalog of the configuration.
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Download the custom font.
    // highlight-download
    guard let remoteURL = URL(string: "https://img.ly/static/example-assets/custom_font_raleway_regular.ttf") else {
      fatalError("Unable to parse URL.")
    }

    let downloadTask = URLSession.shared.downloadTask(with: remoteURL) { downloadURL, _, error in
      if let error = error {
        fatalError("There was an error downloading the file: \(error)")
      }

      if let downloadURL = downloadURL {
        // File was downloaded successfully. Saving it in the temporary directory.
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let localURL = temporaryDirectoryURL.appendingPathComponent(remoteURL.lastPathComponent)

        if FileManager.default.fileExists(atPath: localURL.path) {
          // Remove the file at the destination if it already exists
          try? FileManager.default.removeItem(at: localURL)
        }
        try? FileManager.default.moveItem(at: downloadURL, to: localURL)
        // highlight-download

        // Dispatch to the main queue for any UI work
        // and to prevent race conditions.
        // highlight-queue
        DispatchQueue.main.async {
          self.localURL = localURL
          // highlight-queue

          // Create a reference to the custom font.
          // highlight-object
          let customFont = Font(url: localURL, displayName: "Raleway", fontName: "custom_font_raleway_regular", identifier: "custom_font_raleway_regular")

          // Create a reference to a system font.
          let systemFont = Font(displayName: "Helvetica", fontName: "Helvetica", identifier: "system_font_helvetica")
          // highlight-object

          // Create a `Configuration` object.
          let configuration = Configuration { builder in
            // In this example we are using the default assets for the asset catalog as a base.
            // However, you can also create an empty catalog as well which only contains your
            // custom assets.
            // highlight-catalog
            let assetCatalog = AssetCatalog.defaultItems

            // Add the custom fonts to the asset catalog.
            assetCatalog.fonts.append(contentsOf: [customFont, systemFont])

            // Use the new asset catalog for the configuration.
            builder.assetCatalog = assetCatalog
            // highlight-catalog
          }

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
    presentingViewController?.view.isUserInteractionEnabled = false

    // Start the file download
    downloadTask.resume()
  }

  // Removes the previously downloaded resources.
  private func removeResources() {
    if let localURL = localURL {
      try? FileManager.default.removeItem(at: localURL)
    }
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
