import PhotoEditorSDK
import UIKit

class ConfigurationExampleSwift: Example {
  override func invokeExample() {
    // highlight-build-class
    let configuration = Configuration { builder in
      // highlight-build-class

      // highlight-global-config
      builder.theme.backgroundColor = UIColor.white
      builder.theme.menuBackgroundColor = UIColor.lightGray
      // highlight-global-config

      // highlight-controller-config
      builder.configureCameraViewController { options in
        options.showCancelButton = true
        options.cropToSquare = true
        // highlight-controller-config

        // highlight-closure-config
        options.cameraRollButtonConfigurationClosure = { button in
          button.layer.borderWidth = 2.0
          button.layer.borderColor = UIColor.red.cgColor
        }
        // highlight-closure-config
      }
    }

    let cameraViewController = CameraViewController(configuration: configuration)
    cameraViewController.cancelBlock = { [weak self] in
      self?.presentingViewController?.dismiss(animated: true)
    }

    cameraViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(cameraViewController, animated: true, completion: nil)
  }
}
