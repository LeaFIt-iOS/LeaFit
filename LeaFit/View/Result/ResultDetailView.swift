//
//  ResultDetailView.swift
//  LeaFit
//
//  Created by Arin Juan Sari on 14/06/25.
//

import SwiftUI

struct ResultDetailView: View {
    @State private var date = Date()
    @State private var notes: String = ""
    
    enum Pots: String, CaseIterable, Identifiable {
        case Pot1, Pot2, Pot3
        var id: Self { self }
    }
    
    
    @State private var selectedPot: Pots = .Pot1
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                TabView {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray)
                        .frame(height: 393)
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray)
                        .frame(height: 393)
                }
                .frame(height: 393)
                .tabViewStyle(.page)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 170)
                    .overlay(
                        VStack(alignment: .leading) {
                            DatePicker(
                                "Time",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            
                            Divider()
                            
                            List {
                                Picker(selection: $selectedPot) {
                                    ForEach(Pots.allCases) { pot in
                                        Text(pot.rawValue.capitalized)
                                    }
                                } label: {
                                    Text("Pot")
                                }
                                .listRowInsets(EdgeInsets())
                            }
                            .listStyle(PlainListStyle())
                            
                            HStack {
                                Text("Notes")
                                
                                TextField(text: $notes) {
                                    Text("Add Notes")
                                }
                                .multilineTextAlignment(.trailing)
                            }
                        }
                            .padding()
                    )
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Text("Save")
                }
            }
        }
        .accentColor(LeaFitColors.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LeaFitColors.background)

    }
}

#Preview {
    ResultDetailView()
}
