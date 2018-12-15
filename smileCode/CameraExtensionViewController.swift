//
//  CameraExtensionViewController.swift
//  smileCode
//
//  Created by REO HARADA on 2018/12/15.
//  Copyright © 2018年 reo harada. All rights reserved.
//

import UIKit
import AVFoundation

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func setupCaptureSession() {
        captureSession.sessionPreset = .high
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        devices.forEach { (device) in
            if device.position == AVCaptureDevice.Position.back {
                innerCamera = device
            }
            else if device.position == AVCaptureDevice.Position.front {
                mainCamera = device
            }
        }
        currentDevice = mainCamera
    }
    
    func setupVideoInputOutput() {
        if currentDevice == nil {
            return
        }
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSession.addInput(captureDeviceInput)
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            captureSession.addOutput(videoOutput!)
        }
        catch {
            print("エラー")
        }
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        changeOrientation()
        self.cameraPreviewLayer?.frame = cameraView.bounds
        self.cameraView.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let imgBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            previewciImage = CIImage(cvPixelBuffer: imgBuffer)
        }
    }

    fileprivate func changeOrientation() {
        let orientationValue = UIApplication.shared.statusBarOrientation.rawValue
        if let videoOrientation = AVCaptureVideoOrientation(rawValue: orientationValue) {
            self.cameraPreviewLayer?.connection?.videoOrientation = videoOrientation
        }
    }
    
    @objc func onOrientationDidChange(_ notification: NSNotification) {
        changeOrientation()
    }
}
