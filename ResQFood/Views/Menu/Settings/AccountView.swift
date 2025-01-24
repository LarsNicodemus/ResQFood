//
//  AccountView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State var showUser = false

    var body: some View {
                VStack{
                    Button{
                        navigationPath = NavigationPath()
                        authVM.logout()
                        profileVM.logoutProfile()
                    }label: {
                    ZStack {
                        Text("Logout")
                            .font(Fonts.title2)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .frame(width: 150, alignment: .center)
                            .foregroundStyle(Color("primaryAT"))
                        Image("Strich")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, alignment: .leading)
                            .offset(y: 18)
                    }
                    .padding(.vertical, 8)}
                
                    Button{
                        navigationPath = NavigationPath()
                        authVM.deleteUser()
                    }label: {
                    ZStack {
                        Text("Delete User")
                            .font(Fonts.title2)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .frame(width: 150, alignment: .center)
                            .foregroundStyle(Color("primaryAT"))
                        Image("Strich")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, alignment: .leading)
                            .offset(y: 18)
                    }
                    .padding(.vertical, 8)}
                    
                    Button{
                        showUser.toggle()
                    }label: {
                    ZStack {
                        Text("Passwort ändern")
                            .font(Fonts.title2)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .frame(width: 220, alignment: .center)
                            .foregroundStyle(Color("primaryAT"))
                        Image("Strich")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 230, alignment: .leading)
                            .offset(y: 18)
                    }
                    .padding(.vertical, 8)}
                    if showUser {
                        if showUser {
                            VStack {
                                   SecureField("Aktuelles Passwort", text: $currentPassword)
                                       .textFieldStyle(RoundedBorderTextFieldStyle())
                                   
                                   SecureField("Neues Passwort", text: $newPassword)
                                       .textFieldStyle(RoundedBorderTextFieldStyle())
                                   
                                   Button("Passwort ändern") {
                                       authVM.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                                   }
                                   .primaryButtonStyle()
                                   
                                   if !authVM.errorMessage.isEmpty {
                                       Text(authVM.errorMessage)
                                           .foregroundColor(authVM.errorMessage.contains("erfolgreich") ? .green : .red)
                                           .padding()
                                   }
                               }
                               .padding()
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("surface"))
                .customBackButton()

    }
}

#Preview {
    AccountView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())

}
