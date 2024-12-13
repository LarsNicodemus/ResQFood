//
//  AuthView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isSecure = true
    
    var body: some View {
        VStack {
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

            HStack {
                Spacer()
                Button("Login") {
                    authVM.loginWithEmail()
                }
                .buttonStyle(.borderedProminent)

                Button("überspringen") {
                    authVM.loginAnonymously()
                }
                .font(.system(size: 16))
                Spacer()
            }
            HStack {
                Text("Sie haben noch keinen Zugang? ")
                NavigationLink(
                    "Jetzt registrieren",
                    destination: {
                        RegisterView()
                    })

            }
            .font(.system(size: 16))
            HStack {

            }
        }
        .padding()
        .onAppear {
            if authVM.appUser == nil {
                authVM.email = ""
                authVM.password = ""
            }
        }
    
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
