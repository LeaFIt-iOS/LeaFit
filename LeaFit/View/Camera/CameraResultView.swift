//
//  CameraResultView.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 14/06/25.
//

import SwiftUI

struct CameraResultView: View {
    var image: UIImage
    var originalImage: UIImage
    var onRetake: @MainActor () -> Void
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ResultView(image: image, originalImage: originalImage)) {
                    Text("Next")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Retake", action: onRetake)
            }
        }
    }
}
