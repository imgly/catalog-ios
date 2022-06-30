import PhotoEditorSDK
import SwiftUI
import UIKit

class ShowPhotoCameraSwiftUISwift: Example {
  override func invokeExample() {
    // The steps below are not needed when integrating the SwiftUI `View`s in a SwiftUI
    // application. For SwiftUI, you can directly integrate the `Camera` and `PhotoEditor`
    // instead of wrapping them inside another `View` - in this example the `PhotoCameraSwiftUIView`.
    //
    // Create the `View` that hosts the camera and the photo editor.
    // highlight-present
    var photoEditor = PhotoCameraSwiftUIView()

    // Since we are using UIKit in this example, we need to pass a dismiss action for the
    // `View` being able to dismiss the presenting `UIViewController`.
    photoEditor.dismissAction = {
      self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // Present the camera and photo editor via a `UIHostingController`.
    let hostingController = UIHostingController(rootView: photoEditor)
    hostingController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(hostingController, animated: true, completion: nil)
    // highlight-present
  }
}

// A `View` that hosts the `Camera` and `PhotoEditor` in order
// to use it in this `UIKit` example application.
// highlight-create-view
struct PhotoCameraSwiftUIView: View {
  // The action to dismiss the view.
  internal var dismissAction: (() -> Void)?

  // Create a `Video` from a URL to an image in the app bundle.
  @State private var photo: Photo?

  // Create a variable indicating whether the editor should be presented.
  @State private var pesdkPresented: Bool = false

  // The `PhotoEditModel` that preserves the selected filters from the camera.
  @State private var photoEditModel: PhotoEditModel?

  // Create a `Configuration` object.
  private let configuration = Configuration { builder in
    builder.configureCameraViewController { options in
      // Since we are only using PE.SDK, the camera
      // should only allow to take/select photos.
      options.allowedRecordingModes = [.photo]

      // By default the camera does not show a cancel button,
      // so that it can be embedded into any other view. But since it is
      // presented modally here, a cancel button should be visible.
      options.showCancelButton = true
    }
  }

  // The body of the `View`.
  var body: some View {
    // Create a `Camera`.
    Camera(configuration: configuration)
      // highlight-create-view
      // highlight-event-listeners
      .onDidCancel {
        // The user tapped on the cancel button within the camera. Dismissing the view.
        dismissAction?()
      }
      .onDidSave { result in
        // The user has taken or selected a photo.

        // Passing the `result.model` to the editor to preserve selected filters.
        photoEditModel = result.model

        // The `result.data` argument will contain the photo in JPEG format
        // with all EXIF information in case that a photo has been taken.
        if let data = result.data {
          photo = Photo(data: data)
        }
      }
      // highlight-event-listeners
      // In order for the camera to fill out the whole screen it needs
      // to ignore the safe area.
      .ignoresSafeArea()
      .fullScreenCover(isPresented: $pesdkPresented) {
        dismissAction?()
      } content: {
        if let photo = photo {
          PhotoEditor(photo: photo, configuration: configuration, photoEditModel: photoEditModel)
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
            // In order for the photo editor to fill out the whole screen it needs
            // to ignore the safe area.
            .ignoresSafeArea()
        }
      }
      // Listen to changes of the photo in order to present
      // the editor.
      .onChange(of: photo) { _ in
        pesdkPresented = true
      }
  }
}
