/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


import UIKit
import AVFoundation
import Combine

class ViewController: SwiftyCamViewController {

    @IBOutlet weak var captureButton    : SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton : UIButton!
    @IBOutlet weak var flashButton      : UIButton!
    
    private var subscription: AnyCancellable?
    
	override func viewDidLoad() {
		super.viewDidLoad()
        shouldPrompToAppSettings = true
		maximumVideoDuration = 10.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        flashMode = .auto
        flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        captureButton.buttonEnabled = false
        
        subscribe()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        captureButton.delegate = self
	}
    
    func subscribe() {
        subscription = getPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] swiftyCamStatus in
                guard let self = self else { return }
                
                switch swiftyCamStatus {
                case .sessionStarted:
                    print("Session did start running")
                    self.captureButton.buttonEnabled = true
                case .sessionStopped:
                    print("Session did stop running")
                    self.captureButton.buttonEnabled = false
                case .photoTaken(photo: let photo):
                    let newVC = PhotoViewController(image: photo)
                    self.present(newVC, animated: true, completion: nil)
                case .recordingVideoBegun:
                    print("Did Begin Recording")
                    self.captureButton.growButton()
                    self.hideButtons()
                case .recordingVideoFinished:
                    print("Did finish Recording")
                    self.captureButton.shrinkButton()
                    self.showButtons()
                case .processingVideoFinished(videoUrl: let videoUrl):
                    let newVC = VideoViewController(videoURL: videoUrl)
                    self.present(newVC, animated: true, completion: nil)
                case .cameraSwitched(camera: let camera):
                    print("Camera did change to \(camera.rawValue)")
                case .focused(atPoint: let point):
                    print("Did focus at point: \(point)")
                    self.focusAnimationAt(point)
                case .zoomLevelChanged(zoomLevel: let zoomLevel):
                    print("Zoom level did change. Level: \(zoomLevel)")
                case .notAuthorized:
                    break
                case .configureFailure:
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                case .recordingVideoFailure(err: let err):
                    print(err)
                }
            })
    }
    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        toggleFlashAnimation()
    }
}

// MARK: UI Animations
extension ViewController {
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        if flashMode == .auto {
            flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        } else if flashMode == .on {
            flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        } else if flashMode == .off {
            flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        }
    }
}

