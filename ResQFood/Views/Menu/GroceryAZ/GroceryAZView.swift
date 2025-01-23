//
//  GroceryAZView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 21.12.24.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

struct GroceryAZView: View {
    @StateObject var groceryAZ: GroceryAZViewModel = GroceryAZViewModel()
    @FocusState private var isFocused: Bool
    var filteredGroceries: [GroceryModel] {
        guard let groceries = groceryAZ.groceries else { return [] }
        if groceryAZ.searchInput.isEmpty {
            return groceries.sorted(by: { $0.name < $1.name })
        }
        return
            groceries
            .filter {
                $0.name.localizedCaseInsensitiveContains(groceryAZ.searchInput)
            }
            .sorted(by: { $0.name < $1.name })
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading){
                if !groceryAZ.groceryDetail {
                    ZStack{
                        Text("Lebensmittel A-Z")
                            .font(Fonts.title)
                        Image("Strich")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250)
                            .offset(y: 18)
                    }
                    Text("Das Lebensmittel-Lexikon bietet wertvolle Tipps zur optimalen Lagerung von Lebensmitteln. Zudem informieren wir über deren Haltbarkeit und teilen praktische Ratschläge, um Lebensmittelverschwendung effektiv zu reduzieren.")
                }
                ZStack{
                    TextField("Suche: ", text: $groceryAZ.searchInput)
                        .focused($isFocused)
                        .onChange(of: isFocused) { oldValue, newValue in
                            if newValue {
                                groceryAZ.groceryDetail = false
                                groceryAZ.searchInput = ""
                            }
                        }
                    Image("Strich")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .offset(x: -35, y: 15)
                }
            }
            Spacer()
            if !groceryAZ.groceryDetail && isFocused {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredGroceries, id: \.id) { grocery in
                            GroceryListItem(grocery: grocery)
                            .onTapGesture {
                                groceryAZ.groceryDetail = true
                                groceryAZ.selectedGrocery = grocery.id ?? ""
                                isFocused = false
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                if let grocery = filteredGroceries.first(where: {
                    $0.id == groceryAZ.selectedGrocery
                }) {
                    GroceryDetailView(grocery: grocery)
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color("secondaryContainer"))
        .onChange(of: groceryAZ.searchInput) { oldValue, newValue in
            groceryAZ.groceryDetail = false
        }
        .customBackButton()
    }
}

#Preview {
    GroceryAZView()
}



