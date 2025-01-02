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
                    Text("Lebensmittel A-Z")
                        .font(.system(size: 20, weight: .bold))
                    Text("Das Lebensmittel-Lexikon bietet wertvolle Tipps zur optimalen Lagerung von Lebensmitteln. Zudem informieren wir über deren Haltbarkeit und teilen praktische Ratschläge, um Lebensmittelverschwendung effektiv zu reduzieren.")
                }
                TextField("Suche: ", text: $groceryAZ.searchInput)
                    .focused($isFocused)
                    .onChange(of: isFocused) { oldValue, newValue in
                        if newValue {
                            groceryAZ.groceryDetail = false
                            groceryAZ.searchInput = ""
                        }
                    }
            }

            if !groceryAZ.groceryDetail && isFocused {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredGroceries, id: \.id) { grocery in
                            HStack {
                                Text(grocery.name)
                                    .padding()
                                    .background(Color("primaryContainer"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                Spacer()
                            }
                            .padding(.vertical, 4)
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
                    VStack(alignment: .leading) {
                        Text("Haltbarkeitstipps für \(grocery.name)")
                            .font(.system(size: 18, weight: .bold))
                        Text("Haltbarkeit:")
                            .padding(.top, 4)
                            .fontWeight(.semibold)
                        Text(grocery.shelflife)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        Text("Lagerung:")
                            .padding(.top, 4)
                            .fontWeight(.semibold)
                        Text(grocery.storage)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        Text("Verwendung:")
                            .padding(.top, 4)
                            .fontWeight(.semibold)
                        Text(grocery.usage)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                        Text("Resteverwertung:")
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                        Text(grocery.wastereduction)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color("primaryContainer"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
            }
        }
        .padding()
        .onChange(of: groceryAZ.searchInput) { oldValue, newValue in
            groceryAZ.groceryDetail = false
        }
        .padding(.top, 72)
        Spacer()
    }
}

#Preview {
    GroceryAZView()
}

struct GroceryListItem: View {
    var grocery: GroceryModel
    var body: some View {
        Text(grocery.name)

    }
}

