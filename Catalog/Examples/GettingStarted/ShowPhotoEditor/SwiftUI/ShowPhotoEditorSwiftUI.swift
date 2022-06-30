import PhotoEditorSDK
import SwiftUI
import UIKit

class ShowPhotoEditorSwiftUISwift: Example {
  override func invokeExample() {
    // Create a `Photo` from a URL to a photo in the app bundle.
    let photo = Photo(url: Bundle.main.url(forResource: "LA", withExtension: "jpg")!)

    // The steps below are not needed when integrating the SwiftUI `View`s in a SwiftUI
    // application. For SwiftUI, you can directly integrate the `PhotoEditor` instead
    // of wrapping it inside another `View` - in this example the `PhotoEditorSwiftUIView`.
    //
    // Create the `View` that hosts the photo editor.
    // highlight-present
    var photoEditor = PhotoEditorSwiftUIView(photo: photo)

    // Since we are using UIKit in this example, we need to pass a dismiss action for the
    // `View` being able to dismiss the presenting `UIViewController`.
    photoEditor.dismissAction = {
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // Present the photo editor via a `UIHostingController`.
    let hostingController = UIHostingController(rootView: photoEditor)
    hostingController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(hostingController, animated: true, completion: nil)
    // highlight-present
  }
}

// A `View` that hosts the `PhotoEditor` in order
// to use it in this `UIKit` example application.
// highlight-create-view
struct PhotoEditorSwiftUIView: View {
  // The action to dismiss the view.
  internal var dismissAction: (() -> Void)?

  // The photo being edited.
  let photo: Photo

  var body: some View {
    PhotoEditor(photo: photo)
      // highlight-create-view
      // highlight-event-listeners
      .onDidSave { result in
        // The image has been exported successfully and is passed as an `Data` object in the `result.output.data`.
        // See other examples about how to save the resulting image.
        print("Received image with \(result.output.data.count) bytes")
        dismissAction?()
      }
      .onDidCancel {
        // The user tapped on the cancel button within the editor. Dismissing the editor.
        dismissAction?()
      }
      .onDidFail { error in
        // There was an error generating the photo.
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
