//
//  SettingsOverView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct SettingsOverView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var settingsVM = SettingsViewModel()
    @Binding var navigationPath: NavigationPath
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        VStack {
            ZStack {
                Text("Einstellungen")
                    .font(Fonts.title)
                    .foregroundStyle(Color("primaryAT"))
                Image("Strich")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .offset(y: 18)
            }

            VStack {
                ForEach(SettingsList.allCases) { settingItem in
                    SettingsRow(navigationPath: $navigationPath, settingItem: settingItem)
                }
            }
            .padding(.top, 64)

            Spacer()
        }
        .customBackButton()
        .padding()
        .background(Color("surface"))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
#Preview {
    SettingsOverView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())

}
