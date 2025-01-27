//
//  CustomBackbutton.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 09.01.25.
//

import SwiftUI

struct CustomBackButton: ViewModifier {
    @Environment(\.presentationMode) var presentationMode
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14)
                                .tint(Color("primaryAT"))
                        }
                    }
                }
                
            }.toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)

    }
}

extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButton())
    }
}
