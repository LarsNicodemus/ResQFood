//
//  TextColorModifier.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 10.01.25.
//
import SwiftUI

struct TextColorModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
    }
}

extension View {
    func applyTextColor(_ color: Color) -> some View {
        self.modifier(TextColorModifier(color: color))
    }
}
