//
//  InformationView.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 11/06/25.
//

import SwiftUI

struct InformationView: View {
    @State private var activePage: Int = 0
    @Environment(\.dismiss) var dismiss
    
    let titles: [String] = ["Welcome to", "Identify Problems Early", "What to Do Next? We’ve Got You", "Get the Best Detection Result", "Your Plants, Your Privacy", "Ready to"]
    let contents: [Any] = [InformationContent1View.self, InformationContent2View.self, InformationContent3View.self, InformationContent4View.self, InformationContent5View.self, InformationContent6View.self]
    
    var body: some View {
        VStack {
            Text(titles[activePage])
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundColor(LeaFitColors.primary)
                .lineLimit(2, reservesSpace: true)
                .padding(.top, 50)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            buildContent()
            
            Spacer()
            
            HStack(spacing: 8) {
                if activePage > 0 {
                    Button(action: previousPage) {
                        Text("Previous")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundStyle(LeaFitColors.primary)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
                
                Button(action: nextPage) {
                    Text("Continue")
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
        .accentColor(LeaFitColors.primary)
    }
    
    func buildContent() -> AnyView {
        switch contents[activePage].self {
        case is InformationContent1View.Type: return AnyView( InformationContent1View() )
        case is InformationContent2View.Type: return AnyView( InformationContent2View() )
        case is InformationContent3View.Type: return AnyView( InformationContent3View() )
        case is InformationContent4View.Type: return AnyView( InformationContent4View() )
        case is InformationContent5View.Type: return AnyView( InformationContent5View() )
        case is InformationContent6View.Type: return AnyView( InformationContent6View() )
        default: return AnyView(EmptyView())
        }
    }
    
    func nextPage() {
        if activePage < titles.count - 1 && activePage < contents.count - 1 {
            activePage += 1
        } else {
            dismiss()
        }
    }
    
    func previousPage() {
        if activePage > 0 {
            activePage -= 1
        }
    }
}

#Preview {
    InformationView()
}
