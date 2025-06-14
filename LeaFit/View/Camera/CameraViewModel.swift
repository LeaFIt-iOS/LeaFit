//
//  CameraViewModel.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 13/06/25.
//

import Foundation
import AVFoundation
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var isConfigured = false
    
    @Published var isCapturing = false
    @Published var capturedImage: UIImage?
    @Published var isSessionRunning = false
    
    override init() {
        super.init()
        configure()
    }
    
    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        
        isConfigured = true
    }
    
    func startSession() {
        guard isConfigured else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                }
            }
        }
    }
    
    func capturePhoto() {
        guard !isCapturing else { return }
        isCapturing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.isCapturing {
                self.isCapturing = false
            }
        }
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        print("Photo captured")
        
        guard let data = photo.fileDataRepresentation(),
              let rawImage = UIImage(data: data) else {
            DispatchQueue.main.async {
                self.isCapturing = false
            }
            return
        }
        
        let orientedImage = fixOrientation(for: rawImage)
        
        print("Removing background")
        removeBackground(from: orientedImage) { [weak self] result in
            DispatchQueue.main.async {
                self?.capturedImage = result
                self?.isCapturing = false
                print("Background removed, image ready")
            }
        }
    }
    
    
    func reset() {
        DispatchQueue.main.async {
            self.capturedImage = nil
            self.isCapturing = false
            
            if !self.session.isRunning {
                self.startSession()
            }
        }
    }
    
    private func fixOrientation(for image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    private func removeBackground(from inputImage: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let ciInput = CIImage(image: inputImage) else {
            completion(inputImage)
            return
        }
        
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: ciInput)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    completion(inputImage)
                    return
                }
                
                let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                let ciMask = CIImage(cvPixelBuffer: mask)
                
                let filter = CIFilter.blendWithMask()
                filter.inputImage = ciInput
                filter.maskImage = ciMask
                filter.backgroundImage = CIImage.empty()
                
                if let outputImage = filter.outputImage {
                    let context = CIContext()
                    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                        completion(UIImage(cgImage: cgImage))
                        return
                    } else {
                        print("❌ Could not create CGImage — returning original")
                    }
                } else {
                    print("❌ Blend filter failed — returning original")
                }
            } catch {
                print("❌ Vision error: \(error.localizedDescription) — returning original")
            }
            
            completion(inputImage)
        }
    }
}
