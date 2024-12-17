//
//  PrimaryPickerStyle.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 17.12.24.
//
import SwiftUI

struct PrimaryPickerStyle: ViewModifier {
    var width: CGFloat
    var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .frame(width: width, height: height)
            .foregroundColor(Color("onPrimary"))
            .background(Color("primaryAT"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func primaryPickerStyle(width: CGFloat, height: CGFloat) -> some View {
        self.modifier(PrimaryPickerStyle(width: width, height: height))
    }
}
