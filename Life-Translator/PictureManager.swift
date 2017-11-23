//
//  PictureManager.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 13/06/2017.
//  Copyright © 2017 Robin Champsaur. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

class PictureManager: NSObject, UIImagePickerControllerDelegate {
    
    var analyzeResult : String! = ""
    
    //Action when picture was taken
    func analyzePicture(image: UIImage) {
                
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("can't load Places ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { [] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            // Update UI on main queue
            DispatchQueue.main.async { [] in
                let token = topResult.identifier.components(separatedBy: ",")[0]
                if topResult.confidence * 100 < 18 {
                    self.analyzeResult = "Couldn't find the corresponding object"
                } else {
                    self.analyzeResult = "\(token)"
                }
                print(self.analyzeResult +  "(\(Int(topResult.confidence * 100))%)")
            }
        }
        
        let ciImage = CIImage(image: image)
        let handler = VNImageRequestHandler(ciImage: ciImage!)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    func sendAnalyzeResult() -> String {
        if analyzeResult == "" {
            return "Analyzing..."
        }
        else{
            let aux = analyzeResult
            analyzeResult = ""
            return aux!
        }
    }
    
}
