//
//  HelpAndSettingsView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct HelpAndSettingsView: View {
    @State var messageInput: String = ""
    @State var messageTitleInput: String = ""
    @State var showToast: Bool = false
    @State var showError: Bool = false

    var body: some View {
        VStack{
            VStack {
                Spacer()
                Text("„Hallo! Wie können wir dir helfen? Wenn du Fragen oder Anmerkungen hast, kannst du uns hier direkt erreichen. Wir freuen uns darauf, von dir zu hören!“")
                    .font(.headline)
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                
                if showError && messageTitleInput.isEmpty {
                    Text("Bitte gib einen Betreff ein.")
                        .font(.caption)
                        .foregroundStyle(.error)
                }
                TextField("Betreff..", text: $messageTitleInput)
                    .padding(8)
                    .background(Color("secondaryContainer"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color("primaryAT"), lineWidth: 1)
                    }
                    .padding(.bottom)
                if showError && messageInput.isEmpty {
                    Text("Bitte gib einen Betreff ein.")
                        .font(.caption)
                        .foregroundStyle(.error)
                }
                ZStack {
                    TextEditor(text: $messageInput)
                        .scrollContentBackground(.hidden)
                        .background(Color("secondaryContainer"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color("primaryAT"), lineWidth: 1)
                        }
                        .onSubmit {
                            sendMessage()
                                    }
                    if messageInput.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(
                                    "Bitte gib hier deine Nachricht ein..."
                                )
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        .padding(.leading, 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .padding(.bottom, 8)
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane")
                    Text("Nachricht senden")
                }
                .primaryButtonStyle()
                .padding(.bottom)
                Spacer()
            }
            .padding()
        }
        .overlay(
            Group {
                if showToast {
                    ToastView(
                        message: "Nachricht wurde erfolgreich gesendet!"
                    )
                }
            }
        )
        .customBackButton()
        .background(Color("surface"))

    }
    private func sendMessage(){
        if !messageInput.isEmpty && !messageTitleInput.isEmpty {
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2
            ) {
                withAnimation {
                    showToast = false
                }
            }
            messageInput = ""
            messageTitleInput = ""
            showError = false
        } else {
            showError = true
        }
    }
}

#Preview {
    HelpAndSettingsView()
}
