//
//  ToastView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 17.12.24.
//

import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .transition(.move(edge: .top).combined(with: .opacity))
            .zIndex(1)
    }
}
