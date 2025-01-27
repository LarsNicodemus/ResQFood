//
//  ZStackView2.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//

import SwiftUI

struct PopupView2: View {
    @EnvironmentObject var chatVM: ChatViewModel
    var body: some View {
        ZStack {
            VStack(alignment: .trailing) {
                ZStack {
                    NavigationLink {
                        ProfileView(userID: chatVM.chatMemberID, fromChat: true)
                            .onAppear {
                                        withAnimation {
                                            chatVM.details = false
                                        }
                                    }
                    } label: {
                        Text("Profil")
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .trailing
                    )
                    .padding(.trailing, 4)
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, alignment: .leading)
                        .offset(y: 15)
                }
            }
            .frame(width: 100, height: 70)
            .background(Color("surface"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.trailing)
            .padding(.top, 44)
        }
        .frame(
            maxWidth: .infinity, maxHeight: .infinity,
            alignment: .topTrailing)
    }
}
