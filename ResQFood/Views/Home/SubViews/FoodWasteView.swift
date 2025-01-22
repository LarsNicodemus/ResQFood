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
                // Header
                Text("Lebensmittelverschwendung")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Introduction
                Text("In Deutschland landen jährlich 11 Millionen Tonnen Lebensmittel im Müll. Über die Hälfte davon – etwa 6,5 Millionen Tonnen – stammen aus privaten Haushalten. Das müssen wir ändern!")
                    .font(.body)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)
                
                // Reasons Section
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
                
                // Tips Section
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
                
                // Closing Note
                Text("Gemeinsam können wir Lebensmittelverschwendung reduzieren und Ressourcen schonen. Jeder Beitrag zählt!")
                    .font(.callout)
                    .italic()
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical)
        }.scrollIndicators(.hidden)
    }
    
    // Sample Data
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
