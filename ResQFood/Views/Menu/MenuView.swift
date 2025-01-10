//
//  MenuView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var donVM: DonationViewModel

    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack {
            ZStack {
                Text("Menü")
                    .font(Fonts.title)
                    .foregroundStyle(Color("primaryAT"))
                Image("Strich")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .offset(y: 18)
            }
            if authVM.userNotAnonym {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(MenuList.allCases) { menuItem in
                            HStack {
                                Button {                                    
                                    switch menuItem {
                                    case .profil:
                                            navigationPath.append(NavigationRoute.profil)
                                    case .rewards:
                                        navigationPath.append(NavigationRoute.rewards)
                                    case .chat:
                                        navigationPath.append(NavigationRoute.chat)
                                    case .community:
                                        navigationPath.append(NavigationRoute.community)
                                    case .groceryAZ:
                                        navigationPath.append(NavigationRoute.groceryAZ)
                                    case .recipes:
                                        navigationPath.append(NavigationRoute.recipes)
                                    case .settings:
                                        navigationPath.append(NavigationRoute.settings)
                                    case .partners:
                                        navigationPath.append(NavigationRoute.partners)
                                    }
                                } label: {
                                    if menuItem == .chat {
                                        ZStack {
                                                Text(menuItem.rawValue)
                                                    .lineLimit(nil)
                                                    .multilineTextAlignment(.leading)
                                                    .frame(width: 200, alignment: .leading)
                                                    .foregroundStyle(Color("primaryAT"))
                                            if chatVM.unreadMessagesCount > 0 {
                                                Text("\(chatVM.unreadMessagesCount)")
                                                    .bold()
                                                    .foregroundStyle(Color("tertiary"))
                                            }
                                            Image("Strich")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 135, alignment: .leading)
                                                .offset(x: -35, y: 15)
                                        }
                                        .padding(.vertical, 8)
                                    } else {
                                        ZStack {
                                            Text(menuItem.rawValue)
                                                .lineLimit(nil)
                                                .multilineTextAlignment(.leading)
                                                .frame(width: 200, alignment: .leading)
                                                .foregroundStyle(Color("primaryAT"))
                                            Image("Strich")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 135, alignment: .leading)
                                                .offset(x: -35, y: 15)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                   
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 64)
                }
            }
            else {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(MenuListAnonym.allCases) { menuItem in
                            HStack {
                                Button {
                                    
                                    
                                    switch menuItem {
                                    case .groceryAZ:
                                        navigationPath.append(NavigationRoute.groceryAZ)
                                    case .recipes:
                                        navigationPath.append(NavigationRoute.recipes)
                                    case .settings:
                                        navigationPath.append(NavigationRoute.settings)
                                    case .partners:
                                        navigationPath.append(NavigationRoute.partners)
                                    }
                                } label: {
                                        ZStack {
                                            Text(menuItem.rawValue)
                                                .lineLimit(nil)
                                                .multilineTextAlignment(.leading)
                                                .frame(width: 200, alignment: .leading)
                                                .foregroundStyle(Color("primaryAT"))
                                            Image("Strich")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 135, alignment: .leading)
                                                .offset(x: -35, y: 15)
                                        }
                                        .padding(.vertical, 8)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 64)
                }
            }
        }

        .padding()
    }
}

#Preview {
    MenuView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())
        .environmentObject(ChatViewModel())
        .environmentObject(DonationViewModel())
}



struct MenuItemView: View {
    var text: String
    var body: some View {
        VStack {
            Text(text)
        }
    }
}
