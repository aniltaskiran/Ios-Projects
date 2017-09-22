//
//  ViewController.swift
//  FaceDetectingFromLiveVideo
//
//  Created by kev on 22.09.2017.
//  Copyright © 2017 kev. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLiveVideo()
        startTextDetection()
        
    }
    
    
    func startLiveVideo() {
        //1
        session.sessionPreset = .hd1920x1080
        
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        //2
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //3
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageView.layer.addSublayer(imageLayer)
        imageLayer.frame = self.imageView.frame
        
        session.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
    }
    
    func startTextDetection() {
        let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: self.detectFaceHandler)
        //        textRequest.reportCharacterBoxes = true
        self.requests = [faceRequest]
    }
    
    
    func detectFaceHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results else {
            print("no result")
            return
        }
        
        
        observations.forEach({ (res) in
            DispatchQueue.main.async {
                guard let faceObservation = res as? VNFaceObservation else { return }
                print(faceObservation.boundingBox)
                self.imageView.layer.sublayers?.removeSubrange(1...)
                self.highlightLetters(box: faceObservation.boundingBox)
                
                
            }
            
        })
        
        
        let result = observations.map({$0 as? VNFaceObservation})
        
        DispatchQueue.main.async() {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            for region in result {
                guard let rg = region else {
                    continue
                }
                
                self.highlightLetters(box: rg.boundingBox)
                
                //                    if let boxes = region?.characterBoxes {
                //                        for characterBox in boxes {
                //                            self.highlightLetters(box: characterBox)
                //                        }
                //                    }
            }
        }
        
        
    }
    
    func highlightLetters(box: CGRect) {
        
        let x = imageView.frame.width * box.origin.x
        
        let height = imageView.frame.height * box.height
        
        let y = imageView.frame.height * (1 - box.origin.y) - height
        
        let width = imageView.frame.width * box.width
        
        
        let outline = CALayer()
        outline.frame = CGRect(x: x, y: y, width: width, height: height)
        outline.borderWidth = 1.0
        outline.borderColor = UIColor.blue.cgColor
        
        imageView.layer.addSublayer(outline)
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(self.requests)
            
        } catch {
            print(error)
        }
    }
}
