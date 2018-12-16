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
        var imgOrientation = UIImage.Orientation.upMirrored
        if UIApplication.shared.statusBarOrientation != .landscapeLeft {
            imgOrientation = UIImage.Orientation.downMirrored
        }
        if previewciImage == nil {
            return
        }
        let image = UIImage(ciImage: previewciImage!, scale: 1.0, orientation: imgOrientation)
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
                if !programmingManager.canProgramming() {
                    return
                }
                let ciImage = CIImage(cgImage: cgImage)
                let features = detector?.features(in: ciImage, options: options) as? [CIFaceFeature]
                if features?.count == 0 || features == nil {
                    execProgramming()
                    return
                }
                faceImageView.image = nil
                faceDirectionImageView.image = nil
                faceEyeImageView.image = nil
                
                features?.forEach({ (feature) in
                    let action = programmingManager.programming(feature: feature)
                    programmingManager.insertProgramming()
                    if action == nil { programmingManager.startProgramming() }
                    if feature.leftEyeClosed && feature.rightEyeClosed {
                        self.faceEyeImageView.image = UIImage(named: "face_blink")
                        self.removeActionForLastIndex()
                    }
                    if feature.hasSmile {
                        self.faceImageView.image = UIImage(named: "face_smile")
                        if programmingManager.canCommitProgramming() && !programmingManager.commitingProgramming() {
                            programmingManager.startCommitting()
                            if let a = action {
                                self.addAction(a)
                            }
                        }
                    }
                    else {
                        self.faceImageView.image = UIImage(named: "face_normal")
                    }
                    if feature.faceAngle < Float(-1)*faceLimitAngle {
                        self.faceDirectionImageView.image = UIImage(named: "face_left")
                    }
                    else if feature.faceAngle > faceLimitAngle {
                        self.faceDirectionImageView.image = UIImage(named: "face_right")
                    }
                    else if feature.rightEyeClosed {
                        self.faceEyeImageView.image = UIImage(named: "face_up")
                    }
                    else if feature.leftEyeClosed {
                        self.faceEyeImageView.image = UIImage(named: "face_down")
                    }
                })
            }
            UIGraphicsEndImageContext()
        }
    }
}
