//
//  CameraRulesView.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 12/06/25.
//

import SwiftUI

struct CameraRulesView: View {
    var body: some View {
        VStack(spacing: 34) {
            Text("Get the Best Detection Result")
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(LeaFitColors.primary)
                .lineLimit(2, reservesSpace: true)
                .padding(.top, 50)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            InformationContent4View()
            
            Spacer()
            
            HStack(spacing: 8) {
                NavigationLink(destination: CameraView()) {
                    Text("Start")
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundStyle(LeaFitColors.primary)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(LeaFitColors.button)
                        .cornerRadius(12)
                }
            }
            .padding(.bottom, 100)
            
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 18)
        .background(LeaFitColors.background)
    }
}

#Preview {
    CameraRulesView()
}
