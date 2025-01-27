//
//  Untitled.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 22.01.25.
//

import SwiftUI

struct FoodWasteView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Lebensmittel-")
                    .font(Fonts.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("verschwendung")
                    .font(Fonts.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top, -10)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("In Deutschland landen jährlich 11 Millionen Tonnen Lebensmittel im Müll. Über die Hälfte davon – etwa 6,5 Millionen Tonnen – stammen aus privaten Haushalten. Das müssen wir ändern!")
                    .font(.body)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Hauptgründe für Lebensmittelverschwendung")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(reasons, id: \.self) { reason in
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(reason)
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Tipps zur Vermeidung")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(tips, id: \.self) { tip in
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text(tip)
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Text("Gemeinsam können wir Lebensmittelverschwendung reduzieren und Ressourcen schonen. Jeder Beitrag zählt!")
                    .font(.callout)
                    .italic()
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(Color("OnPrimaryContainer"))
            .padding(.vertical)
        }
        .background(Color("primaryContainer").opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("primaryAT"),lineWidth: 1)
        }
        .scrollIndicators(.hidden)
    }
    
    let reasons = [
        "Fehlende Einkaufsplanung führt zu Übermengen.",
        "Falsche Lagerung verkürzt die Haltbarkeit.",
        "Missverständnisse beim Mindesthaltbarkeitsdatum (MHD)."
    ]
    
    let tips = [
        "Planen Sie Ihre Einkäufe und Mahlzeiten.",
        "Lagern Sie Lebensmittel richtig, um sie länger frisch zu halten.",
        "Vertrauen Sie auf Ihre Sinne: Sehen, Riechen, Schmecken."
    ]
}
