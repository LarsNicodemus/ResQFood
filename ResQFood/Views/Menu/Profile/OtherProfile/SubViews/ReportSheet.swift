//
//  ReportSheet.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 14.01.25.
//

import SwiftUI

struct ReportSheet: View {
    @Binding var sheetPresent: Bool
    @Binding var report: Bool
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

            
            Button{
                
                if !messageInput.isEmpty {
                    
                    withAnimation {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                            sheetPresent = false
                            report = false
                        }
                    }
                }
            } label: {
                Text("User melden")
            }
            .primaryButtonStyle()
            .padding(.bottom)
            .padding(.bottom)
        }
        .background(Color("surface"))

        .overlay(
            Group{
                if showToast {
                    ToastView(
                        message: "User gemeldet!"
                    )
                }
            }
        )
        .background(Color("surface"))
        .padding()
    }
}

#Preview {
    ReportSheet(sheetPresent: .constant(true), report: .constant(true))
}
