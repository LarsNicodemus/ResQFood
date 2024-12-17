//
//  EmailView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 16.12.24.
//

import SwiftUI

struct EmailView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                if let emailError = authVM.emailError {
                    Text(emailError)
                        .font(.caption)
                        .foregroundColor(authVM.isResetEmailSent ? Color("primaryAT") : .red)
                        .padding(.trailing)
                } else {
                    Text(" ")
                        .font(.caption)
                }
            }
            TextField("Email", text: $authVM.email)
                .frame(height: 30)
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onChange(of: authVM.email) { old, new in
                    if !authVM.email.isEmpty {
                        authVM.emailError = nil
                        authVM.emailPasswordError = false
                        authVM.isResetEmailSent = false
                    }
                }
                .onChange(
                    of: authVM.emailAlredyUsed || authVM.emailPasswordError
                ) { old, new in
                    authVM.validateEmail()
                }
                .onChange(
                    of: authVM.isResetEmailSent
                ) { old, new in
                    authVM.validateEmail()
                }
        }
    }
}
