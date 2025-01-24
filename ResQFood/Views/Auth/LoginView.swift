//
//  AuthView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    
    var body: some View {
        VStack {
            RotatingImageView()
                .padding(.bottom, 64)
            EmailView()
            PasswordView()
            .padding(.bottom, 32)
            
            
            
            
            HStack {
                Spacer()
                Button("Login") {
                    authVM.validateFieldsLogin()
                }
                .tint(Color("primaryAT"))
                .foregroundColor(Color("onPrimary"))
                .buttonStyle(.borderedProminent)
                .padding(.trailing, 32)
                
                Button("überspringen") {
                    authVM.loginAnonym()
                }
                .tint(Color("primaryAT"))
                .font(.system(size: 16))
                Spacer()
            }
            .padding(.bottom, 16)

            if authVM.emailPasswordError && !authVM.isResetEmailSent {
                
                HStack {
                    Text("Passwort vergessen?")
                    Button(
                        "Reset per Mail",
                        action: {
                            authVM.sendPasswordResetEmail()
                        })

                }
                .padding(.bottom, 16)

                .tint(Color("primaryAT"))
                .font(.system(size: 16))
            } else if authVM.isResetEmailSent {
                Text("Reset Email wurde gesendet.")
                    .foregroundColor(Color("primaryAT"))
                    .padding(.bottom, 16)

            } else {
                Text(" ")
                    .padding(.bottom, 16)
            }
            HStack {
                Text("Noch keinen Zugang? ")
                NavigationLink(
                    "Jetzt registrieren",
                    destination: {
                        RegisterView()
                            .padding()
                    })

            }
            .tint(Color("primaryAT"))
            .font(.system(size: 16))
        }
        .background(Color("surface"))

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
    LoginView()
        .environmentObject(AuthViewModel())
}
