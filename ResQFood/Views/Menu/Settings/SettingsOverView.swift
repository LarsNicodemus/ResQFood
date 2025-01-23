//
//  SettingsOverView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct SettingsOverView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var navigationPath: NavigationPath

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
            VStack{
                
                        ForEach(SettingsList.allCases) { settingItem in
                            HStack{
                                Button {
                                    switch settingItem {
                                    case .account:
                                        navigationPath.append(NavigationRoute.account)
                                    case .about:
                                        navigationPath.append(NavigationRoute.about)
                                    case .design:
                                        navigationPath.append(NavigationRoute.design)
                                    case .help:
                                        navigationPath.append(NavigationRoute.help)
                                    case .privacy:
                                        navigationPath.append(NavigationRoute.privacy)
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
                                Spacer()
                            }
                        }
                }
            .padding(.top, 64)

            Spacer()
        }
        .customBackButton()
        .padding()
        .background(Color("secondaryContainer"))

    }
}

#Preview {
    SettingsOverView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())

}
