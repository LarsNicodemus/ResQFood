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
    @State private var isSecure = true
    var body: some View {
        VStack{
            TextField("Email", text: $authVM.email)
                .frame(height: 30)
                .padding(8)
                .background(.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack{
                if isSecure {
                    SecureField("Password", text: $authVM.password)
                } else {
                    TextField("Password", text: $authVM.password)
                }
            }
            .frame(height: 30)
            .padding(8)
            .background(.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                HStack{
                    Spacer()
                    Button(action: {
                                isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding(.bottom, 16)
            Button("Registrieren"){
                authVM.register()
            }
            .buttonStyle(.borderedProminent)
        }
        
        .onChange(of: authVM.userIsLoggedIn) { oldValue, newValue in
                    if newValue {
                        dismiss()
                    }
                }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
