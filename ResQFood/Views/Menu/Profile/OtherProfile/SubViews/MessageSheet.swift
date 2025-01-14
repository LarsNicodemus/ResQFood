//
//  MessageSheet.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//

import SwiftUI

struct MessageSheet: View {
    @Binding var sheetPresent: Bool
    @State var messageInput: String = ""
    @State var showToast: Bool = false
    var body: some View {
        VStack{
            ZStack{
                
                TextEditor(text: $messageInput)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                if messageInput.isEmpty {
                    VStack(alignment: .leading){
                        HStack{
                            Text("Bitte gib hier deine Nachricht ein...")
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.leading, 4)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                }
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            
            Button(){
                
                if !messageInput.isEmpty {
                    
                    withAnimation {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                            sheetPresent = false
                        }
                    }
                }
            } label: {
                Image(systemName: "paperplane")
                Text("Nachricht senden")
            }
            .primaryButtonStyle()
            .padding(.bottom)
            .padding(.bottom)
        }
        .overlay(
            Group{
                if showToast {
                    ToastView(
                        message: "Nachricht gesendet"
                    )
                }
            }
        )
        .background(Color("surface"))
        .padding()
    }
}

#Preview {
    MessageSheet(sheetPresent: .constant(true))
}
