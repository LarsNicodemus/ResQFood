//
//  GreetingView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

struct GreetingView: View {
    @ObservedObject var homeVM: HomeViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        ZStack {
            Text(homeVM.greeting)
                .font(Fonts.title3)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(width: 250, alignment: .center)
                .foregroundStyle(Color("primaryAT"))
            Image("Strich")
                .resizable()
                .scaledToFit()
                .frame(width: 260, alignment: .leading)
                .offset(y: 18)
        }
        .onAppear {
            print(
                "HomeView appeared: Current username = \(profileVM.userProfile?.username ?? "nil")"
            )
            Timer.scheduledTimer(
                withTimeInterval: 60, repeats: true
            ) { _ in
                homeVM.greeting = homeVM.getTimeBasedGreeting(
                    name: profileVM.userProfile?.username)
            }
        }
        
    }
}
