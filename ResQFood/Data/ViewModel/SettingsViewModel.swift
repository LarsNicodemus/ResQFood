//
//  SettingsViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

class SettingsViewModel: ObservableObject{
    @Published var messageInput: String = ""
    @Published var messageTitleInput: String = ""
    @Published var showToast: Bool = false
    @Published var showError: Bool = false
    
    
    func sendMessage(){
        if !messageInput.isEmpty && !messageTitleInput.isEmpty {
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2
            ) {
                withAnimation {
                    self.showToast = false
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
