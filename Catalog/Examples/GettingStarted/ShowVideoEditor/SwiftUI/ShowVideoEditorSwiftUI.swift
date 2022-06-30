import SwiftUI
import UIKit
import VideoEditorSDK

class ShowVideoEditorSwiftUISwift: Example {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // The steps below are not needed when integrating the SwiftUI `View`s in a SwiftUI
    // application. For SwiftUI, you can directly integrate the `VideoEditor` instead
    // of wrapping it inside another `View` - in this example the `VideoEditorSwiftUIView`.
    //
    // Create the `View` that hosts the video editor.
    // highlight-present
    var videoEditor = VideoEditorSwiftUIView(video: video)

    // Since we are using UIKit in this example, we need to pass a dismiss action for the
    // `View` being able to dismiss the presenting `UIViewController`.
    videoEditor.dismissAction = {
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // Present the video editor via a `UIHostingController`.
    let hostingController = UIHostingController(rootView: videoEditor)
    hostingController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(hostingController, animated: true, completion: nil)
    // highlight-present
  }
}

// A `View` that hosts the `VideoEditor` in order
// to use it in this `UIKit` example application.
// highlight-create-view
struct VideoEditorSwiftUIView: View {
  // The action to dismiss the view.
  internal var dismissAction: (() -> Void)?

  // The video being edited.
  let video: Video

  var body: some View {
    VideoEditor(video: video)
      // highlight-create-view
      // highlight-event-listeners
      .onDidSave { result in
        // The user exported a new video successfully and the newly generated video is located at `result.output.url` of the returned `VideoEditorResult`. Dismissing the editor.
        print("Received video at \(result.output.url.absoluteString)")
        dismissAction?()
      }
      .onDidCancel {
        // The user tapped on the cancel button within the editor. Dismissing the editor.
        dismissAction?()
      }
      .onDidFail { error in
        // There was an error generating the video.
        print("Editor finished with error: \(error.localizedDescription)")
        // Dismissing the editor.
        dismissAction?()
      }
      // highlight-event-listeners
      // In order for the editor to fill out the whole screen it needs
      // to ignore the safe area.
      .ignoresSafeArea()
  }
}
