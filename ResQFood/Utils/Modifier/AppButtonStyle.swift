//
//  AppButtonStyle.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 17.12.24.
//
import SwiftUI



struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .tint(Color("primaryAT"))
            .foregroundColor(Color("onPrimary"))
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        modifier(PrimaryButtonStyle())
    }
}
