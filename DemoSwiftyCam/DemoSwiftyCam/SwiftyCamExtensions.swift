//
//  Extensions.swift
//  DemoSwiftyCam
//
//  Created by Tsz-Lung on 19/03/2022.
//  Copyright © 2022 Cappsule. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension UIDeviceOrientation {
    var captureVideoOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
}
