//
//  ViewController.swift
//  SeeFood
//
//  Created by Timothy Platt on 14/08/2018.
//  Copyright © 2018 Timothy Platt. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Couldn't convert uiimage to CIImage")
            }
            
            detect(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hot Dog"
                } else {
                    self.navigationItem.title = "Not a Hot Dog"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try! handler.perform([request])
        }
        catch {
            print(error)
        }
    
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}

