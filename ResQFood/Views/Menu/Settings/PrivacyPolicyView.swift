//
//  PrivacyPolicyView.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 11.12.24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Allgemeine Geschäftsbedingungen (AGB) für ResQFood")
                    .font(Fonts.title)
                    .underline(pattern: .dashDot)
                    .foregroundStyle(Color("primaryAT"))
                    .multilineTextAlignment(.center)

                Text("1. Einleitung")
                    .font(.headline)

                Text(
                    "Willkommen bei ResQFood! Diese mobilen Anwendung wurde entwickelt, um Lebensmittelverschwendung zu reduzieren und gleichzeitig Menschen in Not zu unterstützen. Mit der Nutzung der App erklären Sie sich mit den folgenden Allgemeinen Geschäftsbedingungen einverstanden. Bitte lesen Sie diese sorgfältig durch."
                )
                .padding(.bottom)

                Group {
                    Text("2. Nutzung der App")
                        .font(.headline)

                    Text(
                        "ResQFood bietet eine Plattform, auf der Nutzer überschüssige Lebensmittel teilen können. Zu den Hauptfunktionen der App gehören ein Spenden-System, eine Spenden-Suche, eine Lebensmittel A-Z Datenbank über Firebase, eine Rezept-Suche über TheMealDB API sowie eine Echtzeit-Chatfunktion."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("3. Registrierung und Konto")
                        .font(.headline)

                    Text(
                        "Um ResQFood nutzen zu können, müssen Sie sich registrieren und ein Konto erstellen. Sie sind dafür verantwortlich, die Vertraulichkeit Ihrer Kontodaten zu wahren und uns über jede unbefugte Nutzung Ihres Kontos zu informieren."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("4. Datenbanken und APIs")
                        .font(.headline)

                    Text(
                        "Die App nutzt verschiedene Technologien und Frameworks, darunter Firebase, PhotosUI, CoreLocation, MapKit, Imgur API und TheMealDB API. Ihre Nutzung dieser Dienste erfolgt gemäß den Nutzungsbedingungen der jeweiligen Anbieter."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("5. Standortermittlung und Map-Funktion")
                        .font(.headline)

                    Text(
                        "Für die Bereitstellung von Standort-basierten Diensten nutzt die App CoreLocation und MapKit. Sie können die Standortermittlung in den Einstellungen Ihres Geräts deaktivieren, was jedoch die Funktionalität der App einschränken kann."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("6. Rechte und Pflichten der Nutzer")
                        .font(.headline)

                    Text(
                        "Als Nutzer verpflichten Sie sich, keine rechtswidrigen Inhalte über die App zu verbreiten und die App nicht missbräuchlich zu verwenden. ResQFood behält sich das Recht vor, Benutzerkonten zu sperren oder Inhalte zu entfernen, die gegen diese AGB verstoßen."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("7. Geistiges Eigentum")
                        .font(.headline)

                    Text(
                        "Alle Inhalte der App, einschließlich der Custom Farbpalette und Custom Pins für Maps, sind geistiges Eigentum von ResQFood oder den jeweiligen Rechteinhabern. Jegliche Vervielfältigung oder Verbreitung ohne Genehmigung ist untersagt."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("8. Haftungsausschluss")
                        .font(.headline)

                    Text(
                        "ResQFood übernimmt keine Haftung für die Richtigkeit, Vollständigkeit und Aktualität der bereitgestellten Informationen. Die Nutzung der App erfolgt auf eigene Gefahr."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("9. Änderungen der AGB")
                        .font(.headline)

                    Text(
                        "ResQFood behält sich das Recht vor, diese AGB jederzeit zu ändern. Über wesentliche Änderungen werden Sie informiert. Die fortgesetzte Nutzung der App nach der Änderung gilt als Zustimmung zu den geänderten Bedingungen."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("10. Kontakt")
                        .font(.headline)

                    Text(
                        "Für Fragen oder Anmerkungen zu diesen AGB kontaktieren Sie uns bitte unter [Ihre E-Mail-Adresse]."
                    )
                }
                .padding(.bottom)
            }
            .foregroundStyle(Color("OnSecondaryContainer"))
            .padding()
            .background(Color("surface"))
            .padding(.bottom)

            VStack(alignment: .leading, spacing: 16) {
                Text("Datenschutzbestimmungen für ResQFood")
                    .font(Fonts.title)
                    .underline(pattern: .dashDot)
                    .foregroundStyle(Color("primaryAT"))
                    .multilineTextAlignment(.center)

                Text("Ihre Privatsphäre ist uns wichtig.")
                    .font(.headline)

                Text(
                    "ResQFood wurde entwickelt, um Lebensmittelverschwendung zu reduzieren und Menschen zu helfen. Wir verpflichten uns, Ihre persönlichen Daten zu schützen und vertraulich zu behandeln. Diese Datenschutzbestimmungen erläutern, wie wir Ihre Daten sammeln, verwenden, schützen und Ihre Rechte in Bezug auf Ihre Daten."
                )
                .padding(.bottom)

                Group {
                    Text("Welche Daten sammeln wir?")
                        .font(.headline)

                    Text(
                        "Kontodaten: Wenn Sie sich für ResQFood registrieren, sammeln wir Ihren Namen, Ihre E-Mail-Adresse und möglicherweise ein Passwort."
                    )

                    Text(
                        "Standortdaten: Um Ihnen relevante Spenden und Lebensmittelangebote in Ihrer Nähe anzuzeigen, benötigen wir Ihren ungefähren Standort. Sie können Ihre Standortdienste jederzeit in den Einstellungen Ihres Geräts deaktivieren."
                    )

                    Text(
                        "Gespendete Lebensmittel: Wenn Sie Lebensmittel spenden, sammeln wir Informationen über die Art und Menge der Lebensmittel."
                    )

                    Text(
                        "Nachrichten: Wenn Sie die Chatfunktion nutzen, werden Ihre Nachrichten gespeichert."
                    )

                    Text(
                        "Nutzungsdaten: Wir sammeln automatisch Daten über Ihre Nutzung der App, wie z. B. die von Ihnen besuchten Seiten und die Dauer Ihrer Nutzung."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("Wie verwenden wir Ihre Daten?")
                        .font(.headline)

                    Text(
                        "Bereitstellung der App: Ihre Daten werden verwendet, um Ihnen die Funktionen der App zur Verfügung zu stellen, wie z. B. das Erstellen eines Profils, das Suchen nach Spenden und das Chatten mit anderen Nutzern."
                    )

                    Text(
                        "Verbesserung der App: Wir nutzen Ihre Daten, um die App zu verbessern und neue Funktionen zu entwickeln."
                    )

                    Text(
                        "Kommunikation: Wir können Ihre E-Mail-Adresse verwenden, um Ihnen wichtige Informationen über die App oder Änderungen an unseren Datenschutzbestimmungen zu senden."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("Wie schützen wir Ihre Daten?")
                        .font(.headline)

                    Text(
                        "Wir ergreifen angemessene technische und organisatorische Maßnahmen, um Ihre Daten vor unbefugtem Zugriff, Verlust, Missbrauch oder Veränderung zu schützen."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("Ihre Rechte")
                        .font(.headline)

                    Text(
                        "Sie haben das Recht, auf Ihre bei uns gespeicherten Daten zuzugreifen, diese zu berichtigen oder zu löschen. Sie können Ihre Einwilligung zur Datenverarbeitung jederzeit widerrufen."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("Änderungen dieser Datenschutzbestimmungen")
                        .font(.headline)

                    Text(
                        "Wir behalten uns das Recht vor, diese Datenschutzbestimmungen jederzeit zu ändern. Wir werden Sie über wesentliche Änderungen informieren."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("Kontakt")
                        .font(.headline)

                    Text(
                        "Wenn Sie Fragen zu unseren Datenschutzbestimmungen haben, können Sie uns unter [Ihre E-Mail-Adresse] kontaktieren."
                    )
                }
                .padding(.bottom)

                Group {
                    Text("Wichtige Hinweise:")
                        .font(.headline)

                    Text(
                        "Dritte: Wir arbeiten mit Drittanbietern zusammen (z. B. Firebase, TheMealDB, Imgur), die Zugriff auf Ihre Daten haben können. Wir wählen diese Anbieter sorgfältig aus und stellen Verträge sicher, die den Schutz Ihrer Daten gewährleisten."
                    )

                    Text(
                        "Kinder: ResQFood richtet sich nicht an Kinder. Wir sammeln nicht wissentlich Daten von Kindern unter 13 Jahren."
                    )

                    Text(
                        "Sicherheit: Obwohl wir alle Anstrengungen unternehmen, um Ihre Daten zu schützen, können wir die Sicherheit Ihrer Daten im Internet nicht vollständig garantieren."
                    )
                }
                .padding(.bottom)
            }
            .foregroundStyle(Color("OnSecondaryContainer"))
            .padding()
            .background(Color("surface"))
        }
        .background(Color("surface"))
        .customBackButton()

    }
}

#Preview {
    PrivacyPolicyView()
}
