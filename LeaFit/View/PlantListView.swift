//
//  PlantListView.swift
//  LeaFit
//
//  Created by Yonathan Hilkia on 10/06/25.
//

import SwiftUI
import Foundation

struct PlantListView: View {
    let plants: [String]
    let title: String
    
    var body: some View {
        List(plants, id: \.self) { plant in
            Text(plant)
        }
        .navigationTitle(title)
        .scrollContentBackground(.hidden) // hide default list background
        .background(LeaFitColors.background.ignoresSafeArea())
    }
    
    
}

#Preview {
    PlantListView(plants: ["Monstera", "Palm"], title: "Sample Category")
}
