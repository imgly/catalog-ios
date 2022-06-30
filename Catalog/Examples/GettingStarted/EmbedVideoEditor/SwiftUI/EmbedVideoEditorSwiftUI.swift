import SwiftUI
import UIKit
import VideoEditorSDK

class EmbedVideoEditorSwiftUISwift: Example {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // The steps below are not needed when integrating the SwiftUI `View`s in a SwiftUI
    // application. For SwiftUI, you can directly integrate the `Camera` and `VideoEditor`
    // instead of wrapping them inside another `View` - in this example the `EmbeddedVideoEditorSwiftUIView`.
    //
    // Create the `View` that hosts the camera and the video editor.
    // highlight-present
    var videoEditor = EmbeddedVideoEditorSwiftUIView(video: video)

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
struct EmbeddedVideoEditorSwiftUIView: View {
  // The action to dismiss the view.
  internal var dismissAction: (() -> Void)?

  // The video being edited.
  let video: Video

  // Create a `Configuration` object.
  private let configuration = Configuration { builder in
    builder.configureVideoEditViewController { options in
      // The `VideoEditor` currently does not support to display the
      // toolbar in the navigation bar yet. Therefore, the editor
      // should keep the default toolbar.
      options.navigationControllerMode = .useToolbar
    }
  }

  // The body of the `View`.
  var body: some View {
    NavigationView {
      VideoEditor(video: video, configuration: configuration)
        // highlight-create-view
        // highlight-event-listeners
        .onDidSave { result in
          // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor.
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

        // Add a title.
        .navigationTitle(Text("VE.SDK"))

        // Use inline display mode.
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
