//
//  SettingsRow.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 27.01.25.
//

import SwiftUI

struct SettingsRow: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @Binding var navigationPath: NavigationPath
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    var settingItem: SettingsList
    var body: some View {
        HStack {
            if settingItem == .design {
                HStack{
                    ZStack {
                        Text("Dark Mode")
                            .font(Fonts.title3)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .frame(width: 150, alignment: .leading)
                            .foregroundStyle(Color("primaryAT"))
                        Image("Strich")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, alignment: .leading)
                            .offset(y: 18)
                    }
                        Toggle("", isOn: $isDarkMode)
                            .toggleStyle(
                                SwitchToggleStyle(
                                    tint: Color("primaryAT"))
                            )
                            .preferredColorScheme(authVM.isDarkMode ? .dark : .light)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                            .padding(.vertical, 8)
                }
                
            } else {
                Button {
                    switch settingItem {
                    case .account:
                        navigationPath.append(
                            NavigationRoute.account)
                    case .about:
                        navigationPath.append(NavigationRoute.about)
                    case .help:
                        navigationPath.append(NavigationRoute.help)
                    case .privacy:
                        navigationPath.append(
                            NavigationRoute.privacy)
                    default:
                        break
                    }
                } label: {
                    ZStack {
                        Text(settingItem.rawValue)
                            .font(Fonts.title3)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .frame(width: 150, alignment: .leading)
                            .foregroundStyle(Color("primaryAT"))
                        Image("Strich")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, alignment: .leading)
                            .offset(y: 18)
                    }
                    .padding(.vertical, 8)
                }
            }
            Spacer()
        }
    }
}

