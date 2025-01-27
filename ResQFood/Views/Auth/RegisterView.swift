//
//  RegisterView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            RotatingImageView()
                .padding(.bottom, 64)
            EmailView()
            PasswordView()
            .padding(.bottom, 32)
            Button("Registrieren"){
                authVM.validateFieldsRegister()
            }
            .tint(Color("primaryAT"))
            .foregroundColor(Color("onPrimary"))
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 32)

            HStack {
                Text("Sie haben schon einen Zugang? ")
                Button(
                    "zum Login",
                    action: {
                        dismiss()
                    })
            }
            .tint(Color("primaryAT"))
            .font(.system(size: 16))
        }
        .background(Color("surface"))

        .onChange(of: authVM.user) { old, new in
            if new != nil {
                dismiss()
            } else {
                print("hier liegt vllt der fehler?")
            }
        }
        .onAppear {
            if authVM.appUser == nil {
                authVM.email = ""
                authVM.password = ""
                authVM.emailError = nil
                authVM.passwordError = nil
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
