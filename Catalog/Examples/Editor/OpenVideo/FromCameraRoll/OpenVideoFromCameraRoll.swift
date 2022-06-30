import AVFoundation
import Foundation
import UniformTypeIdentifiers
import VideoEditorSDK

class OpenVideoFromCameraRollSwift: Example, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // We recommend using the old `UIImagePickerController` class instead of the newer `PHPickerViewController`
    // due to video import issues for some MP4 files encoded with non-ffmpeg codecs. We've filed a bug report
    // with Apple regarding this issue.
    // highlight-instantiate-picker
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    imagePicker.mediaTypes = [UTType.movie.identifier]
    // highlight-instantiate-picker

    // Setting `videoExportPreset` to passthrough will not reencode the video before passing it to
    // the delegate methods.
    // highlight-passthrough
    imagePicker.videoExportPreset = AVAssetExportPresetPassthrough
    // highlight-passthrough

    // Present the image picker modally.
    imagePicker.modalPresentationStyle = .fullScreen
    presentingViewController?.present(imagePicker, animated: true, completion: nil)
  }

  // MARK: - UIImagePickerControllerDelegate

  // highlight-imagepicker-delegate
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    guard let videoURL = info[.mediaURL] as? URL else {
      fatalError()
    }

    // Dismiss the image picker and present the video editor after dismissal is done
    presentingViewController?.dismiss(animated: true, completion: {
      // Create a `Video` from the picked video URL
      let video = Video(url: videoURL)

      // Create a video editor and pass it the video. Make this class the delegate of it to handle export and cancelation.
      let videoEditViewController = VideoEditViewController(videoAsset: video)
      videoEditViewController.delegate = self

      // Present the video editor.
      videoEditViewController.modalPresentationStyle = .fullScreen
      self.presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
    })
  }
  // highlight-imagepicker-delegate

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    presentingViewController?.dismiss(animated: true, completion: nil)
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
