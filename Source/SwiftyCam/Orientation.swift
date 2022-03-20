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

import Foundation
import AVFoundation
import UIKit
import CoreMotion

class Orientation  {
    
    var shouldUseDeviceOrientation: Bool = false
    
    fileprivate var deviceOrientation: UIDeviceOrientation?
    fileprivate let coreMotionManager = CMMotionManager()
    
    init() {
        coreMotionManager.accelerometerUpdateInterval = 0.1
    }
    
    func start() {
        deviceOrientation = UIDevice.current.orientation
        coreMotionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else {
                return
            }
            self?.handleAccelerometerUpdate(data: data)
        }
    }
  
    func stop() {
        coreMotionManager.stopAccelerometerUpdates()
        deviceOrientation = nil
    }
    
    func getImageOrientation(for camera: SwiftyCamViewController.CameraSelection) -> UIImage.Orientation {
        guard
            shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation
        else {
            return camera == .rear ? .right : .leftMirrored
        }
        
        switch deviceOrientation {
        case .landscapeLeft:
            return camera == .rear ? .up : .downMirrored
        case .landscapeRight:
            return camera == .rear ? .down : .upMirrored
        case .portraitUpsideDown:
            return camera == .rear ? .left : .rightMirrored
        default:
            return camera == .rear ? .right : .leftMirrored
        }
    }
    
    func getPreviewLayerOrientation() -> AVCaptureVideoOrientation {
        // Depends on layout orientation, not device orientation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            switch windowScene.interfaceOrientation {
            case .unknown, .portrait:
                return .portrait
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            @unknown default:
                return .portrait
            }
        } else {
            return .portrait
        }
    }
    
    func getVideoOrientation() -> AVCaptureVideoOrientation? {
        guard
            shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation
        else {
            return nil
        }
        
        switch deviceOrientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    private func handleAccelerometerUpdate(data: CMAccelerometerData) {
        if (abs(data.acceleration.y) < abs(data.acceleration.x)) {
            if (data.acceleration.x > 0) {
                deviceOrientation = .landscapeRight
            } else {
                deviceOrientation = .landscapeLeft
            }
        } else {
            if (data.acceleration.y > 0) {
                deviceOrientation = .portraitUpsideDown
            } else {
                deviceOrientation = .portrait
            }
        }
    }
}



