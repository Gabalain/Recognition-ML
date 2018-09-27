//
//  ViewController.swift
//  vision-ML
//
//  Created by Alain Gabellier on 26/09/2018.
//  Copyright © 2018 Alain Gabellier. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraVC: UIViewController {

    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    var flashUsed: Bool!
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureImage: RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowButton!
    @IBOutlet weak var itemsNameLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var answerView: RoundedShadowView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
        
        flashUsed = false
        flashBtn.setTitle("FLASH ON", for: .normal)
        // and show spinner
        self.activityIndicator.isHidden = true
        
        speechSynthesizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
            
        } catch {
            debugPrint(error)
        }
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func flashBtnTapped(_ sender: Any) {
        flashUsed = !flashUsed!
        if flashUsed! {
            flashBtn.setTitle("FLASH OFF", for: .normal)
        } else {
            flashBtn.setTitle("FLASH ON", for: .normal)
        }
    }
    
    @objc func didTapCameraView() {
        // Disactivated buttons
        self.cameraView.isUserInteractionEnabled = false
        // and show spinner
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
        let previewFormatNew = settings.embeddedThumbnailPhotoFormat
        
        settings.previewPhotoFormat = previewFormatNew
        
        if flashUsed {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }
        
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            if classification.confidence < 0.5 {
                let unknownObjectMessage = "Objet non reconnu. Merci de réessayer."
                self.itemsNameLbl.text = unknownObjectMessage
                synthesizeSpeech(fromString: unknownObjectMessage)
                self.confidenceLbl.isHidden = true
                break
            } else {
                let identification = classification.identifier
                self.itemsNameLbl.text = identification
                synthesizeSpeech(fromString: identification)
                
                let confidence = "CONFIDENCE: " + String(Int(classification.confidence * 100)) + "%"
                self.confidenceLbl.isHidden = false
                self.confidenceLbl.text = confidence
                synthesizeSpeech(fromString: confidence)
                break
            }
        }
    }
    
    

}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            // Send to Model for recognition
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
            debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            captureImage.image = image
        }
    }
}

extension CameraVC: AVSpeechSynthesizerDelegate {
    // Finished talking
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Disactivated buttons
        self.cameraView.isUserInteractionEnabled = true
        // and show spinner
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }}
