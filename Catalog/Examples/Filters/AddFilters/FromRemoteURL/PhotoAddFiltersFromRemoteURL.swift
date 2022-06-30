import PhotoEditorSDK
import UIKit

class PhotoAddFiltersFromRemoteURLSwift: Example, PhotoEditViewControllerDelegate {
  // The local locations of the downloaded remote resources.
  private var downloadLocations = [String: URL]()

  // Although the editor supports adding assets with remote URLs, we highly recommend
  // that you manage the download of remote resources yourself, since this
  // gives you more control over the whole process. After successfully downloading
  // the files you should pass the local URLs to the asset catalog of the configuration.
  override func invokeExample() {
    // Create a `Photo` from a URL to an image in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // Filenames of remote assets.
    // highlight-download
    let filterFilename = "custom_lut_invert.png"
    let thumbnailFilename = "custom_filter_category.jpg"

    // All available filenames of the assets.
    let assetFilenames = [filterFilename, thumbnailFilename]

    // Download each of the remote resources.
    assetFilenames.forEach { filename in
      guard let remoteURL = URL(string: "https://img.ly/static/example-assets/\(filename)") else {
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
        let localURL = temporaryDirectoryURL.appendingPathComponent(filename)

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
          self.downloadLocations[filename] = localURL
          // highlight-queue

          // If all resources have been downloaded the editor can be started.
          // highlight-object
          if self.downloadLocations.count == assetFilenames.count {
            // Create a custom LUT filter from the downloaded resources.
            let filterURL = self.downloadLocations[filterFilename]
            let customLUTFilter = LUTEffect(identifier: "custom_lut_filter", lutURL: filterURL!, displayName: "Invert", horizontalTileCount: 5, verticalTileCount: 5)

            // Create a custom DuoTone filter.
            let customDuoToneFilter = DuoToneEffect(identifier: "custom_duotone_filter", lightColor: .yellow, darkColor: .blue, displayName: "Custom")
            // highlight-object

            // Create a `Configuration` object.
            let configuration = Configuration { builder in
              // In this example we are using the default assets for the asset catalog as a base.
              // However, you can also create an empty catalog as well which only contains your
              // custom assets.
              // highlight-catalog
              let assetCatalog = AssetCatalog.defaultItems

              // Add the custom filters to the asset catalog.
              assetCatalog.effects.append(contentsOf: [customLUTFilter, customDuoToneFilter])

              // Use the new asset catalog for the configuration.
              builder.assetCatalog = assetCatalog
              // highlight-catalog

              // Optionally, you can create custom filter groups which group
              // multiple filters into one folder in the filter tool. If you do not
              // create filter groups the filters will appear independent of each
              // other.
              //
              // Create the thumbnail for the filter group from the downloaded resources.
              // highlight-group
              let thumbnailURL = self.downloadLocations[thumbnailFilename]
              let thumbnailData = try? Data(contentsOf: thumbnailURL!)
              let thumbnail = UIImage(data: thumbnailData!)

              // Create the actual filter group.
              let customFilterGroup = Group(identifier: "custom_filter_category", displayName: "Custom", thumbnail: thumbnail, memberIdentifiers: ["custom_lut_filter"])

              // Add the custom filter group to the filter tool.
              builder.configureFilterToolController { options in
                options.filterGroups.append(customFilterGroup)
              }
              // highlight-group
            }

            // Create the photo editor. Make this class the delegate of it to handle export and cancelation.
            let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration)
            photoEditViewController.delegate = self

            // Reenable user interaction. In production you would want to dismiss a progress indicator for example.
            self.presentingViewController?.view.isUserInteractionEnabled = true

            // Present the photo editor.
            photoEditViewController.modalPresentationStyle = .fullScreen
            self.presentingViewController?.present(photoEditViewController, animated: true, completion: nil)
          }
        }
      }

      // Disable user interaction while the download is active. In production you would want to show a progress indicator for example.
      presentingViewController?.view.isUserInteractionEnabled = false

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

  // MARK: - PhotoEditViewControllerDelegate

  func photoEditViewControllerShouldStart(_ photoEditViewController: PhotoEditViewController, task: PhotoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func photoEditViewControllerDidFinish(_ photoEditViewController: PhotoEditViewController, result: PhotoEditorResult) {
    // The image has been exported successfully and is passed as an `Data` object in the `result.output.data`.
    // To create an `UIImage` from the output, use `UIImage(data:)`.
    // See other examples about how to save the resulting image.
    presentingViewController?.dismiss(animated: true, completion: {
      self.removeResources()
    })
  }

  func photoEditViewControllerDidFail(_ photoEditViewController: PhotoEditViewController, error: PhotoEditorError) {
    // There was an error generating the photo.
    print(error.localizedDescription)
    // Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: {
      self.removeResources()
    })
  }

  func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
    // The user tapped on the cancel button within the editor. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: {
      self.removeResources()
    })
  }
}
