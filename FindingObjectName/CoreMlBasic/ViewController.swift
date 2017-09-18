//
//  ViewController.swift
//
//  Created by kev on 17.09.2017.
//  Copyright © 2017 kev. All rights reserved.
//
import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet var cameraView: UIView!
    @IBOutlet var objectNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // here is where we start up the camera
        let captureSession = AVCaptureSession()
        
        // if you can use Camera View like Ios Camera app use .photo
        
        captureSession.sessionPreset = .high
        
        // We use guard for protect our program from error
        
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        
        // Adding Views
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraView.frame
        view.addSubview(cameraView)
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
       
        // Sending the Frame Of Objects
        
        captureSession.addOutput(dataOutput)
        
    }
    
  
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Download the models at https://developer.apple.com/machine-learning/
                guard let model = try? VNCoreMLModel(for: Resnet50().model  ) else { return }
                let request = VNCoreMLRequest(model: model) { (finalReq, err) in
        
        // check the err
        
                    NSLog(String(describing: finalReq.results))
        
                    guard let results = finalReq.results as? [VNClassificationObservation] else { return }
        
                    guard let firstObservation = results.first else { return }
        
                    NSLog(String(describing: firstObservation.identifier), String(describing: firstObservation.confidence))
        
                    DispatchQueue.main.async {
                        self.objectNameLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                    }
        
                }
        
                try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}

