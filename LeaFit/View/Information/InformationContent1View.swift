//
//  InformationContent1View.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 11/06/25.
//

import SwiftUI

struct InformationContent1View: View {
    var body: some View {
        VStack {
            Image("img-information1")
                .resizable()
                .frame(width: 288, height: 228)
                .padding(.bottom, 34)
            
            Text("The easiest way to keep your houseplants happy and healthy. Snap a leaf, detect disease early, and treat your plants with confidence.")
                .font(.system(size: 17, weight: .medium, design: .default))
                .foregroundColor(LeaFitColors.primary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    InformationContent1View()
}
