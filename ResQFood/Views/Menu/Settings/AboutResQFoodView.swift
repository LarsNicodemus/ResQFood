//
//  AboutResQFoodView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct AboutResQFoodView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Vision & Mission")
                    .font(Fonts.title)
                    .frame(maxWidth: .infinity)
                    .underline(pattern: .dashDot)
                    .foregroundStyle(Color("primaryAT"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                
                Section {
                    Text("Unsere Vision")
                        .font(Fonts.title2)
                        .frame(maxWidth: .infinity)
                        .underline(pattern: .dashDot)
                        .foregroundStyle(Color("primaryAT"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    Text("""
                        Wir träumen von einer Welt, in der alle Lebensmittel geschätzt und genutzt werden, ohne dass etwas in der Tonne landet. In unserer Vision arbeitet jeder Mensch und jedes Unternehmen verantwortungsvoll daran, Ressourcen zu schonen und Überschüsse sinnvoll zu teilen.

                        Unsere Vision ist es, dass ResQFood eines Tages überflüssig wird – weil Lebensmittelverschwendung nicht mehr existiert. Bis dahin möchten wir eine Gemeinschaft aufbauen, die aktiv zur Reduzierung von Lebensmittelabfällen beiträgt und zeigt, wie einfach es sein kann, bewusster zu leben.
                        """)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                
                Section {
                    Text("Unsere Mission")
                        .font(Fonts.title2)
                        .frame(maxWidth: .infinity)
                        .underline(pattern: .dashDot)
                        .foregroundStyle(Color("primaryAT"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                    
                    Text("""
                        ResQFood ist mehr als eine App – wir sind eine Bewegung für eine nachhaltige und gerechte Zukunft. Unsere Mission ist es, Menschen mit überschüssigen Lebensmitteln mit denen zu verbinden, die sie benötigen, und so eine Gemeinschaft zu schaffen, die auf Solidarität und gegenseitiger Hilfe basiert.
                        
                        Unsere Ziele:
                        • Lebensmittelverschwendung halbieren bis 2030
                        • Gemeinschaft fördern
                        • Bildung und Inspiration
                        
                        ResQFood steht für Innovation, Nachhaltigkeit und Solidarität. Unser Ziel ist es, nicht nur Lebensmittel zu retten, sondern auch Menschen zu inspirieren, Teil der Lösung zu werden – für unsere Mitmenschen und unseren Planeten.
                        """)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                Text("Macht mit und helft uns, eine nachhaltigere Zukunft zu schaffen!")
                    .font(.headline)
                    .foregroundStyle(Color("primaryAT"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
            }
            .foregroundStyle(Color("OnSecondaryContainer"))
            .background(Color("surface"))

            .padding()
        }
        .background(Color("surface"))
        .customBackButton()
    }
}

#Preview {
    AboutResQFoodView()
}
