import UIKit
import VideoEditorSDK

class OpenVideoFromRemoteURLSwift: Example, VideoEditViewControllerDelegate {
  // Save a reference to the downloaded file to remove it when done
  private var localURL: URL?

  override func invokeExample() {
    // Although the editor supports opening a remote URL, we highly recommend
    // that you manage the download of the remote resource yourself, since this
    // gives you more control over the whole process. After successfully downloading
    // the file you should pass a local URL to the downloaded video to the editor.
    // This example demonstrates how to achieve this.
    guard let remoteURL = URL(string: "https://img.ly/static/example-assets/Skater.mp4") else {
      fatalError("Unable to parse URL.")
    }

    // highlight-download
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
        self.localURL = localURL
        // highlight-download

        // Dispatch to the main queue for any UI work
        // highlight-instantiation
        DispatchQueue.main.async {
          // Create a `Video` from the local file URL.
          let video = Video(url: localURL)

          // Create a video editor and pass it the video. Make this class the delegate of it to handle export and cancelation.
          let videoEditViewController = VideoEditViewController(videoAsset: video)
          videoEditViewController.delegate = self
          // highlight-instantiation

          // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
          // highlight-user-interaction
          self.presentingViewController?.view.isUserInteractionEnabled = true

          // Present the video editor.
          videoEditViewController.modalPresentationStyle = .fullScreen
          self.presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
        }
      }
    }

    // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
    presentingViewController?.view.isUserInteractionEnabled = false
    // highlight-user-interaction

    // Start the file download
    downloadTask.resume()
  }

  // MARK: - VideoEditViewControllerDelegate

  func videoEditViewControllerShouldStart(_ videoEditViewController: VideoEditViewController, task: VideoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func videoEditViewControllerDidFinish(_ videoEditViewController: VideoEditViewController, result: VideoEditorResult) {
    // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor
    // and removing the downloaded file.
    presentingViewController?.dismiss(animated: true, completion: {
      if let localURL = self.localURL {
        try? FileManager.default.removeItem(at: localURL)
      }
    })
  }

  func videoEditViewControllerDidFail(_ videoEditViewController: VideoEditViewController, error: VideoEditorError) {
    // There was an error generating the video.
    print(error.localizedDescription)
    // Dismissing the editor and removing the downloaded file.
    presentingViewController?.dismiss(animated: true, completion: {
      if let localURL = self.localURL {
        try? FileManager.default.removeItem(at: localURL)
      }
    })
  }

  func videoEditViewControllerDidCancel(_ videoEditViewController: VideoEditViewController) {
    // The user tapped the cancel button. Dismissing the editor and removing the downloaded file.
    presentingViewController?.dismiss(animated: true, completion: {
      if let localURL = self.localURL {
        try? FileManager.default.removeItem(at: localURL)
      }
    })
  }
}
