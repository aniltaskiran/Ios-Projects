//
//  ViewController.swift
//  FaceDetectingFromImage
//
//  Created by kev on 22.09.2017.
//  Copyright © 2017 kev. All rights reserved.

import UIKit
import Vision

class ViewController: UIViewController {
    
    let images = ["sample", "termi", "wolve"]
    var i = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        detectFace(imageName: images[i])
    }
    @IBAction func handleSwipeRight(_ sender: UISwipeGestureRecognizer) {
    removeSubViews()
    i = i + 1
    if i == 3 {i = 0}
    detectFace(imageName: images[i])
    }
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
    removeSubViews()
    i = i + 1
     if i == 3 {i = 0}
    detectFace(imageName: images[i])
    }
    
    func removeSubViews(){
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
    }
        
    func detectFace(imageName: String) {
        guard let image = UIImage(named: imageName) else { return }
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        let scaledHeight = view.frame.width / image.size.width * image.size.height
        let yForImageView = self.view.frame.height/2 - scaledHeight/2
        
        imageView.frame = CGRect(x:0, y: yForImageView, width: view.frame.width, height: scaledHeight)
        
        
        view.addSubview(imageView)
        
        // import Vision
        
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
                redView.frame = CGRect(x: x, y: y + yForImageView, width: width, height: height)
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

