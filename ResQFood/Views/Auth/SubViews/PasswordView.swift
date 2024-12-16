//
//  PasswordView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import SwiftUI

struct PasswordView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack {
            HStack {
                Spacer()
                if let passwordError = authVM.passwordError {
                    Text(passwordError)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.trailing)
                } else {
                    Text(" ")
                        .font(.caption)
                }
            }
            VStack {

                if authVM.isSecure {
                    SecureField("Password", text: $authVM.password)
                        .onChange(of: authVM.password) { old, new in
                            if !authVM.password.isEmpty {
                                authVM.passwordError = nil
                            }
                        }
                } else {
                    TextField("Password", text: $authVM.password)
                        .onChange(of: authVM.password) { old, new in
                            if !authVM.password.isEmpty {
                                authVM.passwordError = nil
                            }
                        }
                }
            }
            .frame(height: 30)
            .padding(8)
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                HStack {
                    Spacer()
                    Button(action: {
                        authVM.isSecure.toggle()
                    }) {
                        Image(
                            systemName: authVM.isSecure
                                ? "eye.slash.fill" : "eye.fill")
                    }
                    .tint(Color("primaryAT"))
                    .padding(.trailing, 8)
                }
            }
        }
    }
}
