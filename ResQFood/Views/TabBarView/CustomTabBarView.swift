//
//  CustomTabBarView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 20.12.24.
//
import SwiftUI

struct CustomAnimatedTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            ForEach(0..<4) { index in
                TabBarButton(
                    title: tabTitle(for: index),
                    icon: tabIcon(for: index),
                    isSelected: selectedTab == index,
                    namespace: namespace
                ) {
                    withAnimation(.spring()) {
                        selectedTab = index
                    }
                }
            }
        }
        .coordinateSpace(.named("TABBARVIEW"))
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("primaryContainer"))
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Erstellen"
        case 2: return "Spenden"
        case 3: return "Menü"
        default: return ""
        }
    }
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "fridgeicon"
        case 1: return "giveicon"
        case 2: return "receiveicon"
        case 3: return "menuicon"
        default: return ""
        }
    }

    
}

#Preview{
    CustomAnimatedTabBar(selectedTab: .constant(0))
}


struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    @State private var tabLocation: CGRect = .zero

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("primaryAT"))
                            .matchedGeometryEffect(id: "tab", in: namespace)
                            .onGeometryChange(for: CGRect.self, of: {
                                $0.frame(in: .named("TABBARVIEW")) }, action: { newValue in
                                    tabLocation = newValue
                                })
                    }
                }
            )
            .animation(.spring(), value: isSelected)
        }
    }
}
