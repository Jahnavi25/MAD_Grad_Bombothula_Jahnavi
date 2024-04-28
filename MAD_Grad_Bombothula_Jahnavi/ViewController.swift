//
//  ViewController.swift
//  MAD_Grad_Bombothula_Jahnavi
//
//  Created by Jahnavi Bombothula on 4/27/24.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI elements
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    

    // Core ML model and Vision request
    private var classificationRequest: VNCoreMLRequest?
    private let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoreMLModel()
        setupImagePicker()
    }

    private func setupCoreMLModel() {
        // Load the trained ML model
        guard let model = try? VNCoreMLModel(for: MAD_Grad_MyImageClassifier1().model) else {
            fatalError("Failed to load Core ML model")
        }
        
        // Create a Vision request with the model
        classificationRequest = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
            self?.processClassifications(for: request, error: error)
        })
    }

    private func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary // change to .camera if needed
    }

    // Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            categoryLabel.text = "Failed to get the image"
            return
        }
        
        imageView.image = image
        classify(image: image)
    }

    private func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image),
              let request = classificationRequest else { return }
        
        // Perform the classification with proper error handling
        do {
            let handler = try VNImageRequestHandler(ciImage: ciImage, orientation: .up, options: [:])
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error.localizedDescription)")
            categoryLabel.text = "Error processing image"
        }
    }

    // Process classification results
    private func processClassifications(for request: VNRequest, error: Error?) {
            DispatchQueue.main.async { [weak self] in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    self?.categoryLabel.text = "Unable to classify image."
                    return
                }
                // Display the top classification
                self?.categoryLabel.text = "Category: \(topResult.identifier)"
            }
        }


    @IBAction func uploadImageTapped(_ sender: UIButton) {
        present(imagePicker, animated: true)
    }
}

