//
//  ViewController.swift
//  FaceDetectingFromImage
//
//  Created by kev on 22.09.2017.
//  Copyright © 2017 kev. All rights reserved.

import UIKit
import Vision

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detectFace()
    }
    
    func detectFace() {
        guard let image = UIImage(named: "sample") else { return }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let scaledHeight = view.frame.width / image.size.width * image.size.height
        
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        
        
        view.addSubview(imageView)
        
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            if let err = err {
                print("Failed to detect: ", err)
                return
            }
            
            req.results?.forEach({ (res) in
                
                guard let faceObservation = res as? VNFaceObservation else { return }
                
                let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                
                let height = scaledHeight * faceObservation.boundingBox.height
                
                let y = scaledHeight * (1 - faceObservation.boundingBox.origin.y) - height
                
                let width = self.view.frame.width * faceObservation.boundingBox.width
                
                
                
                let redView = UIView()
                redView.backgroundColor = .red
                redView.alpha = 0.4
                redView.frame = CGRect(x: x, y: y, width: width, height: height)
                self.view.addSubview(redView)
            })
            
        }
        
        guard let cgImage = image.cgImage else { return }
        
        
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch let reqErr {
            print("Failed to perform Req", reqErr)
        }
        
        
    }
}

