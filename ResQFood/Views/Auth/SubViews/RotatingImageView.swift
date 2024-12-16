//
//  RotatingImageView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import SwiftUI

struct RotatingImageView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        TimelineView(.animation) { context in
            let timeInterval = context.date.timeIntervalSinceReferenceDate
            let angle = (timeInterval.truncatingRemainder(dividingBy: 50)) * 360 / 50
            
            Image("icon2")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .rotationEffect(.degrees(angle))
        }
    }
    
}
#Preview {
    RotatingImageView()
}
