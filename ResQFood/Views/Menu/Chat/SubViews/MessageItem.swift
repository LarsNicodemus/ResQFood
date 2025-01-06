//
//  MessageItem.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 06.01.25.
//

import SwiftUI

struct MessageItem: View {
    var content: String
    var fromSelf: Bool
    var body: some View {
        HStack {
            if fromSelf {
                Spacer()
            }
            Text(content)
                .foregroundStyle(Color("onPrimary"))
                .padding()
                .background(fromSelf ? Color("primaryAT") : Color("tertiary"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            if !fromSelf {
                Spacer()
            }
        }.listRowSeparator(.hidden)
    }
}

#Preview {
    MessageItem(
        content: "Test Test 123",
        fromSelf: false
    )
}
