//
//  CameraView.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 12/06/25.
//

import SwiftUI
import AVFoundation
import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

struct CameraView: View {
    @State private var capturedImage: UIImage? = nil
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if let image = capturedImage {
                CameraResultView(
                    image: image,
                    onRetake: {
                        withAnimation {
                            capturedImage = nil
                            viewModel.reset()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.startSession()
                        }
                    }
                )
            } else {
                ZStack {
                    CameraPreview(session: viewModel.session)
                        .ignoresSafeArea()
                    
                    ZStack {
                        Rectangle()
                            .foregroundColor(.black.opacity(0.5))
                        Rectangle()
                            .blendMode(.destinationOut)
                            .overlay(
                                Image("img-camera-border")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                
                            )
                            .aspectRatio(1.0, contentMode: .fit)
                            .cornerRadius(30)
                            .padding(.horizontal, 40)
                    }
                    .compositingGroup()
                    .padding(.bottom, 80)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                viewModel.capturePhoto()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 69, height: 69)
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 2).frame(width: 78, height: 78)
                                    )
                            }
                            .disabled(!viewModel.isSessionRunning || viewModel.isCapturing)
                            
                            Spacer()
                        }
                        .padding(.vertical, 40)
                        .background(Color.black)
                    }
                    
                    if viewModel.isCapturing {
                        ZStack {
                            Color.black.opacity(0.5).ignoresSafeArea()
                            ProgressView("Processing...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(12)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
            }
        }
        .background(Color.black)
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onReceive(viewModel.$capturedImage) { newImage in
            guard let image = newImage else { return }
            withAnimation {
                capturedImage = image
            }
        }
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .accentColor(.white)
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
