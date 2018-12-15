//
//  SmileJudgeExtensionViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit

extension ViewController {
    
    func startJudge() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (ti) in
            self.judgeSmile()
        }
    }
    
    fileprivate func judgeSmile() {
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let options = [
            CIDetectorSmile: true,
            CIDetectorEyeBlink: true,
            ]
        print(UIApplication.shared.statusBarOrientation.rawValue)
        print(UIImage.Orientation.leftMirrored.rawValue)
        print(UIImage.Orientation.rightMirrored.rawValue)
        let image = UIImage(ciImage: previewciImage!, scale: 1.0, orientation: UIImage.Orientation.downMirrored)
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: CGPoint(x: 0, y: 0))
        if let img = UIGraphicsGetImageFromCurrentImageContext() {
//            debug用
//            let rect = CGRect(x: 0, y: 0, width: self.cameraView.frame.width, height: self.cameraView.frame.height)
//            let v = UIImageView(image: img)
//            v.contentMode = .scaleAspectFit
//            v.frame = rect
//            self.view.addSubview(v)
            if let cgImage = img.cgImage {
                let ciImage = CIImage(cgImage: cgImage)
                let features = detector?.features(in: ciImage, options: options) as? [CIFaceFeature]
                if features?.count == 0 || features == nil {
                    smileJudgeLabel.text = "誰もいないよ〜"
                    return
                }
                var isSmileString = "普通の顔"
                var directionString = ""
                var eyeString = ""
                features?.forEach({ (feature) in
                    print(feature.bounds)
                    print(feature.hasSmile)
                    print(feature.faceAngle)
                    if feature.leftEyeClosed && feature.rightEyeClosed {
                        eyeString = "両目閉じてる"
                    }
                    else if feature.leftEyeClosed {
                        eyeString = "左目閉じてる"
                    }
                    else if feature.rightEyeClosed {
                        eyeString = "右目閉じてる"
                    }
                    
                    if feature.hasSmile {
                        isSmileString = "笑顔"
                    }
                    else {
                        isSmileString = "普通の顔"
                    }
                    if feature.faceAngle < Float(-1)*faceLimitAngle {
                        directionString = "左向ている"
                    }
                    if feature.faceAngle > faceLimitAngle {
                        directionString = "右向いてる"
                    }
                })
                smileJudgeLabel.text = eyeString + ", " + isSmileString + ", " + directionString
            }
        }
    }
}
