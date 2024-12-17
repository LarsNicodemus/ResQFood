//
//  CustomDatePickerStyle.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 17.12.24.
//
import SwiftUI

struct CustomDatePickerStyle: ViewModifier {
    func body(content: Content) -> some View {
            content
                .background(Color("primaryAT"))
                .foregroundStyle(Color("primaryAT"))
                .tint(Color("onPrimary"))
                .accentColor(Color("primaryAT"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("primaryContainer"), lineWidth: 1)
                )
        
    }
}

extension View {
    func customDatePickerStyle() -> some View {
        self.modifier(CustomDatePickerStyle())
    }
}
