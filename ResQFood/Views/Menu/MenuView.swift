//
//  MenuView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(alignment: .leading){
                    ForEach(MenuList.allCases) { menuItem in
                        HStack{
                            NavigationLink(destination: menuItem.view) {
                                Text(menuItem.rawValue)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 200, alignment: .leading)
                            }
                            .primaryButtonStyle()
                            Spacer()
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding(.top, 72)
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AuthViewModel())
}



struct MenuItemView: View {
    var text: String
    var body: some View {
        VStack {
            Text(text)
        }
    }
}
