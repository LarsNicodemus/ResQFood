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
            TextField("Suche: ", text: $groceryAZ.searchInput)
                .padding()
                .focused($isFocused)
                .onChange(of: isFocused) { oldValue, newValue in
                    if newValue {
                        groceryAZ.groceryDetail = false
                        groceryAZ.searchInput = ""
                    }
                }

            if !groceryAZ.groceryDetail && isFocused {
                List {
                    ForEach(filteredGroceries, id: \.id) { grocery in
                        HStack {
                            Text(grocery.name)
                        }
                        .padding()
                        .background(Color("primaryContainer"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            groceryAZ.groceryDetail = true
                            groceryAZ.selectedGrocery = grocery.id ?? ""
                            isFocused = false
                        }
                    }
                }
                .listStyle(.plain)
            } else {
                if let grocery = filteredGroceries.first(where: {
                    $0.id == groceryAZ.selectedGrocery
                }) {
                    VStack(alignment: .leading) {
                        Text("Haltbarkeitstipps für \(grocery.name)")
                        Text(grocery.shelflife)
                        Text(grocery.storage)
                        Text(grocery.usage)
                        Text(grocery.wastereduction)
                    }
                }
            }
        }
        .onChange(of: groceryAZ.searchInput) { oldValue, newValue in
            groceryAZ.groceryDetail = false
        }
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

struct GroceryModel: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var storage: String
    var shelflife: String
    var usage: String
    var wastereduction: String
}

class GroceryAZViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var description: String = ""
    @Published var storage: String = ""
    @Published var shelflife: String = ""
    @Published var usage: String = ""
    @Published var wastereduction: String = ""
    @Published var groceries: [GroceryModel]? = nil
    @Published var searchInput: String = ""
    @Published var groceryDetail: Bool = false
    @Published var selectedGrocery: String = ""
    private let fb = FirebaseService.shared
    private var listener: ListenerRegistration?

    init() {
        setupGroceryListener()
    }
    deinit {
        listener?.remove()
        listener = nil
    }

    private func setupGroceryListener() {
        listener?.remove()
        listener = nil

        listener = addGroceryListener { groceries in
            self.groceries = groceries
        }
    }

    func addGroceryListener(onChange: @escaping ([GroceryModel]) -> Void)
        -> any ListenerRegistration
    {
        return fb.database
            .collection("groceryaz")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                do {
                    let groceries = try documents.compactMap { snapshot in
                        try snapshot.data(as: GroceryModel.self)
                    }
                    onChange(groceries)
                } catch {
                    print(error)
                }
            }
    }

    var groceryList: [GroceryModel] = [
        GroceryModel(
            name: "Tomaten",
            description:
                "Tomaten sind vielseitige Früchte, die in der Küche universell einsetzbar sind. Sie enthalten viel Vitamin C, Kalium und Lycopin.",
            storage:
                "Lagere Tomaten bei Zimmertemperatur, fern von direktem Sonnenlicht. Im Kühlschrank verlieren sie Aroma, können aber bis zu 7 Tage haltbar sein, wenn sie überreif sind.",
            shelflife:
                "Bei Zimmertemperatur 3–5 Tage, im Kühlschrank bis zu 10 Tage.",
            usage:
                "Perfekt für Salate, Saucen, Suppen oder Pürees. Überreife Tomaten können für Saucen oder passierte Tomaten genutzt werden.",
            wastereduction:
                "Überreife Tomaten einfrieren oder zu Püree verarbeiten. Reste zu Tomatensaucen oder Mark einkochen."
        ),

        GroceryModel(
            name: "Gurken",
            description:
                "Gurken sind kalorienarme, erfrischende Gemüse mit einem hohen Wassergehalt. Sie enthalten Vitamin K und C sowie Antioxidantien.",
            storage:
                "Lagere Gurken bei kühlen Temperaturen, jedoch nicht im Kühlschrank, da sie dort schneller an Frische verlieren. Ideal sind 10–13 °C.",
            shelflife:
                "Bei Zimmertemperatur etwa 3–5 Tage, im Kühlschrank in der Gemüseschublade bis zu 7 Tage.",
            usage:
                "Ideal für Salate, Sandwiches, Smoothies oder als Snack. Gurken können auch zu Pickles verarbeitet werden.",
            wastereduction:
                "Überschüssige Gurken zu Essiggurken einlegen oder in Smoothies verarbeiten."
        ),

        GroceryModel(
            name: "Karotten",
            description:
                "Karotten sind reich an Beta-Carotin, Ballaststoffen und Kalium. Sie eignen sich für Rohkost sowie gekochte Gerichte.",
            storage:
                "Lagere Karotten im Kühlschrank, am besten in einem perforierten Plastikbeutel oder in feuchtem Papier eingewickelt.",
            shelflife:
                "Im Kühlschrank bis zu 2 Wochen, besonders lange haltbar, wenn sie ohne Grün gelagert werden.",
            usage:
                "Perfekt für Suppen, Eintöpfe, Rohkostsalate oder zum Backen (z. B. Karottenkuchen).",
            wastereduction:
                "Weiche Karotten in kaltem Wasser auffrischen oder für Brühen und Suppen verwenden."
        ),

        GroceryModel(
            name: "Zwiebeln",
            description:
                "Zwiebeln sind aromatische Knollen, die in fast jedem herzhaften Gericht verwendet werden können. Sie enthalten viele Antioxidantien und schwefelhaltige Verbindungen.",
            storage:
                "An einem kühlen, trockenen und dunklen Ort lagern. Kontakt mit Kartoffeln vermeiden, da diese die Zwiebeln schneller verderben lassen.",
            shelflife:
                "3–4 Wochen bei richtiger Lagerung, geschnittene Zwiebeln im Kühlschrank nur wenige Tage.",
            usage:
                "Geeignet für Saucen, Suppen, Eintöpfe, Pfannengerichte oder als Basis für viele Gerichte.",
            wastereduction:
                "Angeschnittene Zwiebeln einfrieren oder direkt weiterverarbeiten."
        ),

        GroceryModel(
            name: "Knoblauch",
            description:
                "Knoblauch ist eine aromatische Zutat mit hohem Gehalt an Allicin, das gesundheitsfördernde Eigenschaften hat.",
            storage:
                "Trocken, dunkel und kühl lagern, idealerweise in einem luftdurchlässigen Behälter.",
            shelflife:
                "Ungeöffnet mehrere Wochen, geschnitten oder gepresst nur wenige Tage im Kühlschrank.",
            usage:
                "Perfekt für Saucen, Marinaden, Suppen oder als Gewürz in herzhaften Gerichten.",
            wastereduction:
                "Geschälte Zehen einfrieren oder in Öl einlegen (im Kühlschrank lagern)."
        ),

        GroceryModel(
            name: "Weißkohl",
            description:
                "Weißkohl ist ein vielseitiges Gemüse, das reich an Ballaststoffen und Vitamin C ist.",
            storage:
                "Im Kühlschrank in der Gemüseschublade, am besten in einem perforierten Plastikbeutel oder Frischhaltefolie.",
            shelflife: "Bis zu 2 Wochen im Kühlschrank.",
            usage: "Ideal für Krautsalat, Eintöpfe, Suppen oder als Beilage.",
            wastereduction:
                "Übrig gebliebenen Kohl zu Sauerkraut fermentieren oder einfrieren."
        ),

        GroceryModel(
            name: "Paprika",
            description:
                "Paprika ist reich an Vitamin C, Beta-Carotin und Antioxidantien. Sie gibt Gerichten Süße und Farbe.",
            storage: "Im Kühlschrank, vorzugsweise in der Gemüseschublade.",
            shelflife: "Im Kühlschrank 1–2 Wochen.",
            usage:
                "Ideal für Salate, gefüllte Paprika, Saucen oder zum Grillen.",
            wastereduction:
                "Paprika in Streifen schneiden und einfrieren oder für Suppen und Saucen nutzen."
        ),

        GroceryModel(
            name: "Zucchini",
            description:
                "Zucchini ist kalorienarm und vielseitig, reich an Vitamin C und Ballaststoffen.",
            storage: "Im Kühlschrank, am besten in einem perforierten Beutel.",
            shelflife: "Bis zu 1 Woche im Kühlschrank.",
            usage:
                "Für Pfannengerichte, Suppen, Aufläufe oder als Zoodles (Zucchini-Nudeln).",
            wastereduction:
                "Reste raspeln und einfrieren, z. B. für Suppen oder Kuchen."
        ),

        GroceryModel(
            name: "Champignons",
            description:
                "Champignons sind kalorienarm, proteinreich und enthalten viele B-Vitamine.",
            storage:
                "Im Kühlschrank in einer Papiertüte oder offen in der Gemüseschublade.",
            shelflife: "Frisch etwa 3–5 Tage im Kühlschrank.",
            usage: "Für Suppen, Saucen, Pfannengerichte oder Rohkost.",
            wastereduction:
                "Champignons vor dem Verderb anbraten und einfrieren."
        ),
        GroceryModel(
            name: "Äpfel",
            description:
                "Äpfel sind vielseitige Früchte, die reich an Ballaststoffen, Vitamin C und Antioxidantien sind.",
            storage:
                "An einem kühlen, trockenen Ort oder im Kühlschrank lagern. Trenne Äpfel von anderen Früchten, da sie Ethylen abgeben.",
            shelflife:
                "Bei Zimmertemperatur 1–2 Wochen, im Kühlschrank bis zu 4 Wochen.",
            usage: "Perfekt als Snack, für Apfelkuchen, Kompott oder Saft.",
            wastereduction:
                "Weiche Äpfel zu Apfelmus oder Smoothies verarbeiten."
        ),
        GroceryModel(
            name: "Bananen",
            description:
                "Bananen sind eine schnelle Energiequelle, reich an Kalium und Vitamin B6.",
            storage:
                "Lagere sie bei Zimmertemperatur und trenne sie, um den Reifeprozess zu verlangsamen.",
            shelflife:
                "3–7 Tage bei Zimmertemperatur, geschälte Bananen können eingefroren werden.",
            usage: "Ideal für Snacks, Smoothies, Bananenbrot oder Desserts.",
            wastereduction:
                "Überreife Bananen einfrieren oder für Bananenbrot verwenden."
        ),
        GroceryModel(
            name: "Zitronen",
            description:
                "Zitronen sind reich an Vitamin C und Antioxidantien, ideal für frische Aromen in Speisen.",
            storage: "Im Kühlschrank, vorzugsweise in einer luftdichten Tüte.",
            shelflife:
                "Bei Zimmertemperatur etwa 1 Woche, im Kühlschrank bis zu 3 Wochen.",
            usage:
                "Perfekt für Getränke, Dressings, Desserts oder als Zutat in herzhaften Gerichten.",
            wastereduction: "Zitronensaft auspressen und einfrieren."
        ),
        GroceryModel(
            name: "Orangen",
            description:
                "Orangen sind saftige Zitrusfrüchte, reich an Vitamin C und Ballaststoffen.",
            storage: "Bei Zimmertemperatur oder im Kühlschrank aufbewahren.",
            shelflife:
                "Bei Zimmertemperatur etwa 1 Woche, im Kühlschrank bis zu 2 Wochen.",
            usage: "Ideal zum Naschen, für Säfte, Desserts oder Marmeladen.",
            wastereduction:
                "Orangenschale abreiben und einfrieren, Saft pressen und aufbewahren."
        ),
        GroceryModel(
            name: "Mandarinen",
            description:
                "Mandarinen sind süß, saftig und reich an Vitamin C sowie Antioxidantien.",
            storage: "Bei Zimmertemperatur oder im Kühlschrank lagern.",
            shelflife:
                "1 Woche bei Zimmertemperatur, im Kühlschrank bis zu 2 Wochen.",
            usage: "Perfekt als Snack, für Salate, Desserts oder Marmeladen.",
            wastereduction:
                "Schale für Tee oder Zesten nutzen, Saft einfrieren."
        ),
        GroceryModel(
            name: "Limetten",
            description:
                "Limetten sind kleine, aromatische Zitrusfrüchte, ideal für Getränke und Gerichte.",
            storage: "Im Kühlschrank oder bei kühler Zimmertemperatur.",
            shelflife:
                "Bei Zimmertemperatur bis zu 1 Woche, im Kühlschrank bis zu 3 Wochen.",
            usage: "Für Getränke, Dressings, Marinaden oder Desserts.",
            wastereduction:
                "Saft pressen und einfrieren, Schale abreiben und trocknen."
        ),
        GroceryModel(
            name: "Blaubeeren",
            description:
                "Blaubeeren sind reich an Antioxidantien, Vitamin C und Ballaststoffen.",
            storage:
                "Im Kühlschrank in einer flachen, offenen Schale oder einem perforierten Behälter.",
            shelflife: "4–7 Tage im Kühlschrank.",
            usage: "Perfekt für Smoothies, Joghurt, Desserts oder als Snack.",
            wastereduction:
                "Frische Blaubeeren einfrieren oder zu Marmelade verarbeiten."
        ),
        GroceryModel(
            name: "Himbeeren",
            description:
                "Himbeeren sind empfindliche Beeren, reich an Antioxidantien und Vitamin C.",
            storage: "Im Kühlschrank in einer flachen, offenen Schale lagern.",
            shelflife: "2–3 Tage im Kühlschrank.",
            usage: "Für Desserts, Smoothies, Joghurt oder Marmelade.",
            wastereduction: "Himbeeren einfrieren oder sofort verarbeiten."
        ),
        GroceryModel(
            name: "Erdbeeren",
            description:
                "Erdbeeren sind süße Beeren, reich an Vitamin C und Antioxidantien.",
            storage:
                "Ungewaschen im Kühlschrank in einer offenen Schale lagern.",
            shelflife: "2–3 Tage im Kühlschrank.",
            usage: "Ideal für Desserts, Smoothies, Marmelade oder als Snack.",
            wastereduction: "Reife Erdbeeren pürieren und einfrieren."
        ),
        GroceryModel(
            name: "Pfirsiche",
            description:
                "Pfirsiche sind saftige Früchte, reich an Ballaststoffen und Vitamin C.",
            storage:
                "Bei Zimmertemperatur reifen lassen, danach im Kühlschrank aufbewahren.",
            shelflife:
                "Reif etwa 1–3 Tage bei Zimmertemperatur, im Kühlschrank bis zu 5 Tage.",
            usage: "Perfekt für Desserts, Smoothies, Salate oder Marmelade.",
            wastereduction: "Überreife Pfirsiche pürieren oder einfrieren."
        ),
        GroceryModel(
            name: "Nektarinen",
            description:
                "Nektarinen sind ähnlich wie Pfirsiche, jedoch mit glatter Haut und ebenso reich an Ballaststoffen und Vitamin C.",
            storage: "Wie Pfirsiche lagern.",
            shelflife:
                "1–3 Tage bei Zimmertemperatur, bis zu 5 Tage im Kühlschrank.",
            usage: "Ideal für Obstsalate, Desserts oder als Snack.",
            wastereduction:
                "Reife Früchte für Kompott oder Smoothies verwenden."
        ),
        GroceryModel(
            name: "Kiwi",
            description:
                "Kiwi ist eine exotische Frucht, reich an Vitamin C, Vitamin K und Ballaststoffen.",
            storage:
                "Bei Zimmertemperatur reifen lassen, danach im Kühlschrank lagern.",
            shelflife: "1–2 Wochen im Kühlschrank.",
            usage: "Perfekt als Snack, für Salate, Desserts oder Smoothies.",
            wastereduction:
                "Geschälte Kiwi einfrieren oder für Sorbets verwenden."
        ),
        GroceryModel(
            name: "Birnen",
            description:
                "Birnen sind saftige Früchte, reich an Ballaststoffen und Vitamin C.",
            storage:
                "Bei Zimmertemperatur reifen lassen, danach im Kühlschrank lagern.",
            shelflife:
                "3–5 Tage bei Zimmertemperatur, im Kühlschrank bis zu 1 Woche.",
            usage: "Ideal für Kompott, Kuchen, Smoothies oder Salate.",
            wastereduction: "Überreife Birnen pürieren oder einkochen."
        ),
        GroceryModel(
            name: "Weintrauben",
            description:
                "Weintrauben sind saftige Früchte, reich an Antioxidantien, Vitamin C und K.",
            storage: "Im Kühlschrank in einer perforierten Tüte oder Schale.",
            shelflife: "5–7 Tage im Kühlschrank.",
            usage: "Für Snacks, Salate, Desserts oder als Traubensaft.",
            wastereduction: "Trauben einfrieren oder zu Saft verarbeiten."
        ),
        GroceryModel(
            name: "Pflaumen",
            description:
                "Pflaumen sind süße Früchte, reich an Ballaststoffen, Vitamin C und Antioxidantien.",
            storage:
                "Bei Zimmertemperatur reifen lassen, danach im Kühlschrank aufbewahren.",
            shelflife:
                "Reif etwa 1–2 Tage bei Zimmertemperatur, im Kühlschrank bis zu 5 Tage.",
            usage: "Ideal für Kuchen, Kompott oder Marmelade.",
            wastereduction: "Reife Pflaumen pürieren oder einfrieren."
        ),
        GroceryModel(
            name: "Wassermelone",
            description:
                "Wassermelonen sind erfrischende Früchte, reich an Wasser und Vitamin C.",
            storage: "Ganz bei Zimmertemperatur, angeschnitten im Kühlschrank.",
            shelflife:
                "Ganz etwa 1–2 Wochen, geschnitten 3–5 Tage im Kühlschrank.",
            usage: "Für Snacks, Salate, Smoothies oder Desserts.",
            wastereduction: "Überreste pürieren und als Sorbet einfrieren."
        ),
        GroceryModel(
            name: "Mango",
            description:
                "Mango ist eine tropische Frucht, reich an Vitamin C, A und Antioxidantien.",
            storage:
                "Bei Zimmertemperatur reifen lassen, danach im Kühlschrank lagern.",
            shelflife:
                "Reif 1–2 Tage bei Zimmertemperatur, im Kühlschrank bis zu 5 Tage.",
            usage: "Ideal für Smoothies, Desserts, Chutneys oder als Snack.",
            wastereduction: "Mango pürieren und einfrieren."
        ),
        GroceryModel(
            name: "Papaya",
            description:
                "Papayas sind exotische Früchte, reich an Vitamin C, A und Ballaststoffen.",
            storage:
                "Bei Zimmertemperatur reifen lassen, danach im Kühlschrank lagern.",
            shelflife:
                "Reif etwa 1–2 Tage bei Zimmertemperatur, im Kühlschrank bis zu 5 Tage.",
            usage: "Perfekt für Smoothies, Desserts oder Salate.",
            wastereduction: "Fruchtfleisch pürieren und einfrieren."
        ),
        GroceryModel(
            name: "Gouda",
            description:
                "Gouda ist ein halb-harter Käse mit mildem, leicht süßlichem Geschmack. Er enthält viel Kalzium und Eiweiß.",
            storage:
                "Im Kühlschrank, in Pergamentpapier oder Frischhaltefolie eingewickelt, und anschließend in einem luftdichten Behälter aufbewahren.",
            shelflife:
                "1–2 Wochen im Kühlschrank nach dem Öffnen, je nach Reifegrad.",
            usage:
                "Ideal zum Überbacken, für Sandwiches, Salate oder als Snack.",
            wastereduction:
                "Reste in kleine Würfel schneiden und für Käseplatten oder Saucen verwenden."
        ),
        GroceryModel(
            name: "Emmentaler",
            description:
                "Emmentaler ist ein milder, leicht nussiger Hartkäse mit einer charakteristischen Lochbildung und hohem Kalziumgehalt.",
            storage:
                "Im Kühlschrank in Frischhaltefolie oder einem Käsepapier, damit er atmungsaktiv bleibt.",
            shelflife: "2–3 Wochen im Kühlschrank nach dem Öffnen.",
            usage:
                "Perfekt für Sandwiches, zum Überbacken, in Quiches oder für Käseplatten.",
            wastereduction:
                "Übrig gebliebenen Käse in Würfel schneiden und in Saucen oder Eintöpfen verwenden."
        ),
        GroceryModel(
            name: "Camembert",
            description:
                "Camembert ist ein weicher, cremiger Käse mit einer weißen Edelschimmelrinde und einem milden, leicht würzigen Geschmack.",
            storage:
                "Im Kühlschrank, idealerweise in Papier oder in einer Käsebox.",
            shelflife: "1–2 Wochen im Kühlschrank nach dem Öffnen.",
            usage:
                "Ideal auf Brot, in Salaten, als Bestandteil von Käseplatten oder für heiße Zubereitungen wie gebackener Camembert.",
            wastereduction:
                "Reste in Scheiben schneiden und in gebackenem Zustand auf Brot oder in Salaten verwenden."
        ),
        GroceryModel(
            name: "Quark",
            description:
                "Quark ist ein frischer, mild-saurer Frischkäse, der reich an Eiweiß und Kalzium ist.",
            storage:
                "Im Kühlschrank, am besten in einem luftdichten Behälter, um die Frische zu bewahren.",
            shelflife: "Bis zu einer Woche im Kühlschrank nach dem Öffnen.",
            usage:
                "Ideal für Dips, Desserts, als Brotaufstrich oder in Kuchen und Gebäck.",
            wastereduction:
                "Überreste in Smoothies oder als Basis für Salatdressings verwenden."
        ),
        GroceryModel(
            name: "Joghurt",
            description:
                "Joghurt ist ein fermentiertes Milchprodukt, das probiotische Kulturen enthält und gut für die Verdauung ist.",
            storage: "Im Kühlschrank, immer gut verschlossen.",
            shelflife: "Bis zu einer Woche nach dem Öffnen, je nach Sorte.",
            usage:
                "Perfekt als Snack, in Smoothies, Müsli oder als Zutat für Saucen.",
            wastereduction:
                "Joghurt in Desserts oder Pfannkuchenteig verwenden, um ihn zu verwerten."
        ),
        GroceryModel(
            name: "Butter",
            description:
                "Butter ist ein fettreiches Milchprodukt, das sich ideal zum Kochen, Braten oder für Gebäck eignet.",
            storage:
                "Im Kühlschrank, in einem gut verschlossenen Behälter, um Geruchsübertragung zu verhindern. Bei Zimmertemperatur nur für kurze Zeit.",
            shelflife: "1–2 Wochen im Kühlschrank nach dem Öffnen.",
            usage:
                "Ideal zum Backen, Kochen, auf Brot oder als Zutat in Saucen und Teigen.",
            wastereduction:
                "Butterreste in kleine Portionen einfrieren und nach Bedarf auftauen."
        ),
        GroceryModel(
            name: "Margarine",
            description:
                "Margarine ist eine pflanzliche Alternative zu Butter und enthält oft ungesättigte Fettsäuren.",
            storage:
                "Im Kühlschrank, um die Frische zu erhalten und Oxidation zu verhindern.",
            shelflife: "2–3 Wochen im Kühlschrank nach dem Öffnen.",
            usage: "Zum Kochen, Backen oder als Brotaufstrich.",
            wastereduction:
                "Übrig gebliebene Margarine in luftdichte Behälter umfüllen und bei Bedarf verwenden."
        ),
        GroceryModel(
            name: "Sahne",
            description:
                "Sahne ist ein fettreiches Milchprodukt, das sich gut für süße und herzhafte Gerichte eignet.",
            storage:
                "Im Kühlschrank, gut verschlossen, um Gerüche und Oxidation zu vermeiden.",
            shelflife: "Bis zu einer Woche im Kühlschrank nach dem Öffnen.",
            usage:
                "Perfekt für Saucen, Suppen, Desserts oder zum Schlagen für Toppings.",
            wastereduction:
                "Übrig gebliebene Sahne einfrieren und später in Saucen oder Suppen verwenden."
        ),
        GroceryModel(
            name: "Schmand",
            description:
                "Schmand ist ein cremiges, leicht säuerliches Milchprodukt, das ähnliche Eigenschaften wie saure Sahne hat.",
            storage: "Im Kühlschrank, in einem luftdichten Behälter.",
            shelflife: "Bis zu einer Woche im Kühlschrank nach dem Öffnen.",
            usage:
                "Ideal für Dips, auf Kartoffeln, in Suppen oder zum Verfeinern von Saucen.",
            wastereduction:
                "Reste in Dips oder Saucen verarbeiten oder als Zutat für Quiche verwenden."
        ),
        GroceryModel(
            name: "Frischkäse",
            description:
                "Frischkäse ist ein weicher, mild schmeckender Käse, der vielseitig einsetzbar ist.",
            storage:
                "Im Kühlschrank, gut verschlossen, um die Frische zu bewahren.",
            shelflife: "Bis zu einer Woche im Kühlschrank nach dem Öffnen.",
            usage:
                "Ideal für Brotaufstriche, Dips, in Kuchen oder für herzhafte Snacks.",
            wastereduction:
                "Reste in Dips oder zum Verfeinern von Saucen verwenden."
        ),
        GroceryModel(
            name: "Mozzarella",
            description:
                "Mozzarella ist ein weicher, milder Käse, der besonders in der italienischen Küche beliebt ist. Er enthält wenig Fett und viel Eiweiß.",
            storage:
                "Im Kühlschrank, idealerweise in Salzlake oder in Frischhaltefolie.",
            shelflife: "1–2 Wochen im Kühlschrank nach dem Öffnen.",
            usage:
                "Perfekt für Pizza, Salate (z.B. Caprese), Pasta oder als Snack.",
            wastereduction:
                "Mozzarella kann in kleinere Stücke geschnitten und eingefroren oder in Salaten verwendet werden."
        ),
        GroceryModel(
            name: "Schweinefleisch",
            description:
                "Schweinefleisch ist vielseitig und enthält eine gute Menge an Protein und B-Vitaminen. Je nach Teilstück variiert der Fettgehalt.",
            storage:
                "Im Kühlschrank bei 0–4°C, am besten in Frischhaltefolie oder einem luftdichten Behälter. Bei längerem Aufbewahren einfrieren.",
            shelflife:
                "Frisch: 1–3 Tage im Kühlschrank, eingefroren bis zu 6 Monate.",
            usage:
                "Ideal für Braten, Schnitzel, Steaks, Eintöpfe oder Wurstwaren.",
            wastereduction:
                "Übrig gebliebenes Schweinefleisch kann eingefroren oder zu Eintöpfen und Suppen verarbeitet werden."
        ),
        GroceryModel(
            name: "Rindfleisch",
            description:
                "Rindfleisch ist ein hervorragender Proteinlieferant, reich an Eisen und B-Vitaminen, besonders in mageren Teilen.",
            storage:
                "Im Kühlschrank bei 0–4°C, eingewickelt in Frischhaltefolie oder einem luftdichten Behälter.",
            shelflife:
                "Frisch: 2–3 Tage im Kühlschrank, eingefroren bis zu 12 Monate.",
            usage:
                "Perfekt für Steaks, Braten, Hackfleisch, Gulasch oder Suppen.",
            wastereduction:
                "Übrig gebliebenes Rindfleisch kann zu Eintöpfen, Chili oder Sandwiches verarbeitet werden."
        ),
        GroceryModel(
            name: "Hähnchenfleisch",
            description:
                "Hähnchenfleisch ist eine magere Proteinquelle, die wenig Fett enthält und gut verdaulich ist.",
            storage:
                "Im Kühlschrank bei 0–4°C, gut verpackt, um den Kontakt mit Luft zu minimieren.",
            shelflife:
                "Frisch: 1–2 Tage im Kühlschrank, eingefroren bis zu 9 Monate.",
            usage:
                "Ideal für Braten, Grillen, Eintöpfe, Hähnchensalate oder für Sandwiches.",
            wastereduction:
                "Übrig gebliebenes Hähnchenfleisch kann in Suppen, Salaten oder als Füllung für Wraps verwendet werden."
        ),
        GroceryModel(
            name: "Putenfleisch",
            description:
                "Putenfleisch ist mager und enthält viel Eiweiß, ideal für eine kalorienbewusste Ernährung.",
            storage:
                "Im Kühlschrank bei 0–4°C in Frischhaltefolie oder einem luftdichten Behälter.",
            shelflife:
                "Frisch: 1–2 Tage im Kühlschrank, eingefroren bis zu 9 Monate.",
            usage:
                "Perfekt für Braten, Grillen, Putenbrust, Eintöpfe oder Sandwiches.",
            wastereduction:
                "Reste können zu Suppen, Salaten oder in Wraps verarbeitet werden."
        ),
        GroceryModel(
            name: "Lachs",
            description:
                "Lachs ist reich an Omega-3-Fettsäuren, Eiweiß und Vitamin D.",
            storage:
                "Im Kühlschrank bei 0–4°C in Frischhaltefolie oder einem luftdichten Behälter.",
            shelflife:
                "Frisch: 1–2 Tage im Kühlschrank, eingefroren bis zu 6 Monate.",
            usage:
                "Ideal für gebratenen Lachs, Lachsfilets, Sushi, in Salaten oder als Lachsaufstrich.",
            wastereduction:
                "Übrig gebliebenen Lachs kann man in Salaten oder als Füllung für Wraps verwenden."
        ),
        GroceryModel(
            name: "Thunfisch frisch",
            description:
                "Frischer Thunfisch ist reich an Eiweiß und Omega-3-Fettsäuren und hat eine feste Textur.",
            storage:
                "Im Kühlschrank bei 0–4°C, am besten in Frischhaltefolie eingewickelt und innerhalb von 1–2 Tagen verbrauchen.",
            shelflife:
                "Frisch: 1–2 Tage im Kühlschrank, eingefroren bis zu 3 Monate.",
            usage: "Ideal zum Grillen, Braten oder für Sushi und Salate.",
            wastereduction:
                "Reste in Salaten oder für Thunfischsalat verwenden."
        ),
        GroceryModel(
            name: "Forelle",
            description:
                "Forelle ist ein fettarmer Fisch, reich an Omega-3-Fettsäuren und Vitaminen.",
            storage:
                "Im Kühlschrank bei 0–4°C, gut verpackt in Frischhaltefolie oder einem luftdichten Behälter.",
            shelflife: "Frisch: 1–2 Tage im Kühlschrank.",
            usage:
                "Ideal zum Braten, Grillen oder in Eintöpfen und Fischgerichten.",
            wastereduction:
                "Reste können in Fischsuppen oder Fischsalaten verwendet werden."
        ),
        GroceryModel(
            name: "Kabeljau",
            description:
                "Kabeljau ist ein magerer Fisch mit festem Fleisch und einem milden Geschmack. Er ist reich an Eiweiß und Vitamin B12.",
            storage: "Im Kühlschrank bei 0–4°C, gut verpackt.",
            shelflife:
                "Frisch: 1–2 Tage im Kühlschrank, eingefroren bis zu 6 Monate.",
            usage:
                "Ideal zum Braten, Grillen, in Eintöpfen oder Fischfrikadellen.",
            wastereduction:
                "Übrig gebliebenen Kabeljau in Fischsuppen oder -salaten verarbeiten."
        ),
        GroceryModel(
            name: "Salami",
            description:
                "Salami ist ein luftgetrockneter, gewürzter Wurstaufschnitt, der in verschiedenen Varianten erhältlich ist.",
            storage:
                "An einem kühlen, trockenen Ort oder im Kühlschrank, gut verpackt.",
            shelflife: "2–3 Wochen im Kühlschrank nach dem Öffnen.",
            usage:
                "Ideal als Snack, auf Pizza, in Sandwiches oder für Antipasti.",
            wastereduction:
                "Übrig gebliebene Salami kann in Pizza, Sandwiches oder Suppen verwendet werden."
        ),
        GroceryModel(
            name: "Schinken",
            description:
                "Schinken ist gepökeltes und/oder geräuchertes Fleisch, das in verschiedenen Varianten erhältlich ist.",
            storage:
                "Im Kühlschrank, gut verpackt oder in Frischhaltefolie gewickelt.",
            shelflife:
                "1–2 Wochen im Kühlschrank nach dem Öffnen, je nach Sorte.",
            usage: "Ideal für Sandwiches, Salate, auf Pizza oder in Eintöpfen.",
            wastereduction:
                "Schinkenreste können in Quiches, Omeletts oder in Sandwiches verwendet werden."
        ),
        GroceryModel(
            name: "Luftgetrockneter Schinken",
            description:
                "Luftgetrockneter Schinken ist ein fermentiertes, gepökeltes Fleisch, das über einen langen Zeitraum getrocknet wird. Er hat einen intensiven Geschmack.",
            storage:
                "Im Kühlschrank, gut verpackt in Frischhaltefolie oder in einem luftdichten Behälter.",
            shelflife: "2–4 Wochen im Kühlschrank, je nach Verpackung.",
            usage: "Ideal für Antipasti, auf Pizza, in Salaten oder zu Käse.",
            wastereduction:
                "Reste in kleinen Würfeln zu Salaten oder als Beilage zu Gerichten verwenden."
        ),
        GroceryModel(
            name: "Müsli",
            description:
                "Müsli ist eine Mischung aus Haferflocken, getrockneten Früchten, Nüssen und Samen, die sich hervorragend als Frühstück eignet.",
            storage:
                "In einem luftdichten Behälter an einem kühlen, trockenen Ort.",
            shelflife: "2–3 Monate, wenn richtig gelagert.",
            usage:
                "Ideal mit Joghurt oder Milch als Frühstück oder Snack. Kann auch in Smoothies oder als Topping für Desserts verwendet werden.",
            wastereduction:
                "Reste in Joghurt oder Quark mischen, um eine leckere Zwischenmahlzeit zu erhalten."
        ),
        GroceryModel(
            name: "Haferflocken",
            description:
                "Haferflocken sind reich an Ballaststoffen und bieten eine gute Quelle für langanhaltende Energie. Sie sind ideal für Frühstück und Gebäck.",
            storage:
                "In einem luftdichten Behälter an einem kühlen, trockenen Ort.",
            shelflife: "6–12 Monate, je nach Lagerung.",
            usage:
                "Für Porridge, Müsliriegel, als Zutat in Kuchen oder als Bindemittel in Rezepten.",
            wastereduction:
                "Übrig gebliebene Haferflocken in Smoothies oder als Müsli in Kombination mit Joghurt verwenden."
        ),
        GroceryModel(
            name: "Mehl",
            description:
                "Mehl ist eine Grundzutat in vielen Backrezepten und wird aus verschiedenen Getreidesorten wie Weizen, Roggen oder Dinkel gewonnen.",
            storage: "In einem luftdichten Behälter, kühl und trocken.",
            shelflife: "6–12 Monate, je nach Sorte und Lagerbedingungen.",
            usage:
                "Ideal für Brot, Kuchen, Gebäck, Pfannkuchen oder zum Andicken von Saucen.",
            wastereduction:
                "Mehl in luftdichten Behältern aufbewahren, um Feuchtigkeit und Schimmelbildung zu vermeiden."
        ),
        GroceryModel(
            name: "Reis",
            description:
                "Reis ist ein Grundnahrungsmittel, das als Beilage oder in verschiedenen Gerichten verwendet wird. Er enthält vor allem Kohlenhydrate und wenig Fett.",
            storage:
                "An einem kühlen, trockenen Ort, in einem luftdichten Behälter.",
            shelflife: "1–2 Jahre, je nach Sorte.",
            usage:
                "Ideal als Beilage, in Pfannengerichten, Suppen oder als Füllung für Gemüse.",
            wastereduction:
                "Reisreste in Suppen, Eintöpfen oder als Füllung für Wraps oder gefüllte Paprika verwenden."
        ),
        GroceryModel(
            name: "Porridge",
            description:
                "Porridge ist ein cremiger Haferbrei, der meist mit Haferflocken und Milch oder Wasser zubereitet wird. Es ist eine gesunde Frühstücksoption.",
            storage:
                "In einem luftdichten Behälter an einem kühlen, trockenen Ort.",
            shelflife: "3–6 Monate, je nach den Zutaten und Lagerung.",
            usage:
                "Ideal als Frühstück oder Snack, kann mit Früchten, Nüssen oder Honig verfeinert werden.",
            wastereduction: "Reste als Snack oder in einem Smoothie verwenden."
        ),
        GroceryModel(
            name: "Quinoa",
            description:
                "Quinoa ist ein glutenfreies Getreide, das eine gute Quelle für pflanzliches Eiweiß und Ballaststoffe darstellt.",
            storage:
                "An einem kühlen, trockenen Ort, in einem luftdichten Behälter.",
            shelflife: "1 Jahr.",
            usage:
                "Perfekt als Beilage, in Salaten, Eintöpfen oder als Frühstück.",
            wastereduction:
                "Quinoa-Reste können zu Salaten, in Pfannengerichten oder als Füllung für Gemüse verwendet werden."
        ),
        GroceryModel(
            name: "Couscous",
            description:
                "Couscous ist ein schnell zubereitetes Getreide, das aus Hartweizengrieß besteht. Es ist eine gute Quelle für Kohlenhydrate.",
            storage:
                "An einem kühlen, trockenen Ort, in einem luftdichten Behälter.",
            shelflife: "6–12 Monate.",
            usage:
                "Ideal als Beilage, in Salaten oder als Basis für Gemüse- oder Fleischgerichte.",
            wastereduction:
                "Übrig gebliebenen Couscous in Pfannengerichte oder als Füllung für Gemüse verwenden."
        ),
        GroceryModel(
            name: "Bulgur",
            description:
                "Bulgur ist ein vorgekochtes, getrocknetes Weizenkorn, das schnell zubereitet werden kann. Es ist eine gute Quelle für Ballaststoffe.",
            storage:
                "In einem luftdichten Behälter an einem kühlen, trockenen Ort.",
            shelflife: "1 Jahr.",
            usage:
                "Perfekt als Beilage, in Salaten (z.B. Taboulé), als Füllung oder in Pfannengerichten.",
            wastereduction:
                "Reste in Salaten oder als Zutat für Gemüse- oder Fleischgerichte verwenden."
        ),
        GroceryModel(
            name: "Vollkornbrot",
            description:
                "Vollkornbrot wird aus Mehl hergestellt, das aus dem gesamten Getreidekorn gemahlen wird und somit mehr Ballaststoffe, Vitamine und Mineralstoffe enthält.",
            storage:
                "In einer Brotbox oder einem luftdichten Behälter an einem kühlen, trockenen Ort.",
            shelflife: "3–5 Tage, je nach Frische.",
            usage:
                "Ideal für Sandwiches, Toast oder als Beilage zu Suppen und Eintöpfen.",
            wastereduction:
                "Übrig gebliebenes Brot in Scheiben schneiden und einfrieren oder zu Semmelbröseln verarbeiten."
        ),
        GroceryModel(
            name: "Roggenbrot",
            description:
                "Roggenbrot hat einen etwas intensiveren Geschmack als Weizenbrot und enthält mehr Ballaststoffe.",
            storage: "In einer Brotbox oder einem luftdichten Behälter.",
            shelflife: "3–5 Tage, je nach Frische.",
            usage:
                "Ideal für Sandwiches, Toast oder als Beilage zu herzhaften Gerichten.",
            wastereduction:
                "Reste können zu Croutons oder Semmelbröseln verarbeitet werden."
        ),
        GroceryModel(
            name: "Weißbrot",
            description:
                "Weißbrot ist ein leichtes, weiches Brot aus raffiniertem Mehl. Es enthält weniger Ballaststoffe und Vitamine als Vollkornbrot.",
            storage:
                "In einer Brotbox oder einem luftdichten Behälter an einem kühlen, trockenen Ort.",
            shelflife: "2–3 Tage, je nach Frische.",
            usage: "Ideal für Sandwiches, Toast oder als Beilage.",
            wastereduction:
                "Reste können eingefroren oder zu Semmelbröseln verarbeitet werden."
        ),
        GroceryModel(
            name: "Petersilie",
            description:
                "Petersilie ist ein vielseitiges Kraut, das in der Küche häufig für Garnierungen und als Gewürz verwendet wird. Sie ist reich an Vitamin C, Vitamin K und Antioxidantien.",
            storage:
                "Im Kühlschrank, idealerweise in einem Glas mit Wasser oder in einem feuchten Tuch eingewickelt.",
            shelflife: "1 Woche im Kühlschrank.",
            usage:
                "Perfekt als Garnitur für Suppen, Salate, Saucen und als Würze in diversen Gerichten.",
            wastereduction:
                "Übrig gebliebene Petersilie einfrieren oder in Saucen und Eintöpfen verwenden."
        ),
        GroceryModel(
            name: "Schnittlauch",
            description:
                "Schnittlauch hat einen milden, zwiebelartigen Geschmack und eignet sich besonders für frische Salate, Dips und als Garnitur.",
            storage:
                "An einem kühlen Ort im Kühlschrank, in einem Glas Wasser oder in einem feuchten Tuch.",
            shelflife: "1 Woche im Kühlschrank.",
            usage: "Ideal für Salate, Dips, auf Rührei oder in Suppen.",
            wastereduction:
                "Übrig gebliebenen Schnittlauch einfrieren oder in Saucen verwenden."
        ),
        GroceryModel(
            name: "Basilikum",
            description:
                "Basilikum hat einen aromatischen Geschmack und ist besonders in der mediterranen Küche beliebt. Es enthält Vitamin K und Antioxidantien.",
            storage:
                "Im Kühlschrank in einem Glas Wasser oder bei Zimmertemperatur, in einem feuchten Tuch.",
            shelflife:
                "3–5 Tage bei Zimmertemperatur, bis zu einer Woche im Kühlschrank.",
            usage:
                "Perfekt für Pesto, Salate, Pizza oder als Garnitur für Saucen.",
            wastereduction:
                "Übrig gebliebenes Basilikum kann zu Pesto verarbeitet oder eingefroren werden."
        ),
        GroceryModel(
            name: "Pfeffer",
            description:
                "Pfeffer ist eines der beliebtesten Gewürze der Welt, das in ganzen Körnern oder gemahlen erhältlich ist. Er enthält Piperin, das die Verdauung fördert.",
            storage: "An einem trockenen, kühlen Ort, vor Licht geschützt.",
            shelflife: "Unbegrenzt, wenn richtig gelagert.",
            usage:
                "Perfekt für nahezu jedes Gericht, um Würze und Tiefe zu verleihen.",
            wastereduction:
                "Ganze Pfefferkörner länger aufbewahren und bei Bedarf frisch mahlen."
        ),
        GroceryModel(
            name: "Salz",
            description:
                "Salz ist ein grundlegendes Gewürz, das in der Küche für die Zubereitung und als Geschmacksverstärker verwendet wird.",
            storage:
                "An einem trockenen, kühlen Ort, vor Feuchtigkeit geschützt.",
            shelflife: "Unbegrenzt, wenn richtig gelagert.",
            usage:
                "Ideal zum Würzen von Gerichten, Saucen, Salaten oder zum Konservieren von Lebensmitteln.",
            wastereduction:
                "Übrig gebliebenes Salz kann für die Zubereitung von Einmachgemüse oder in Dips verwendet werden."
        ),
        GroceryModel(
            name: "Paprikapulver",
            description:
                "Paprikapulver wird aus getrockneten Paprikaschoten hergestellt und verleiht Gerichten eine milde bis scharfe Würze. Es enthält viel Vitamin C.",
            storage: "An einem trockenen, kühlen Ort, vor Licht geschützt.",
            shelflife: "1 Jahr, je nach Lagerung.",
            usage:
                "Ideal für Saucen, Eintöpfe, Fleischgerichte oder als Garnitur.",
            wastereduction:
                "Übrig gebliebenes Paprikapulver in Marinaden oder Dips verwenden."
        ),
        GroceryModel(
            name: "Senf",
            description:
                "Senf ist eine würzige Sauce, die aus Senfkörnern hergestellt wird und in verschiedenen Varianten wie scharf oder mild erhältlich ist.",
            storage:
                "An einem kühlen, trockenen Ort, nach dem Öffnen im Kühlschrank.",
            shelflife:
                "1 Jahr, nach dem Öffnen bis zu 6 Monate im Kühlschrank.",
            usage:
                "Ideal als Dip, in Dressings, zu Fleisch oder als Würze für Saucen.",
            wastereduction:
                "Übrig gebliebenen Senf in Saucen oder Marinaden verwenden."
        ),
        GroceryModel(
            name: "Ketchup",
            description:
                "Ketchup ist eine süß-säuerliche Tomatensauce, die in vielen westlichen Gerichten als Dip oder Begleitung dient.",
            storage: "Nach dem Öffnen im Kühlschrank aufbewahren.",
            shelflife: "6 Monate nach dem Öffnen.",
            usage:
                "Ideal als Dip zu Pommes, Burgern, Würstchen oder in Saucen.",
            wastereduction:
                "Übrig gebliebenen Ketchup in Saucen oder Marinaden verwenden."
        ),
        GroceryModel(
            name: "BBQ Sauce",
            description:
                "BBQ-Sauce ist eine süß-rauchige Sauce, die vor allem zu gegrilltem Fleisch serviert wird. Sie enthält Tomaten, Essig, Zucker und Gewürze.",
            storage: "Im Kühlschrank nach dem Öffnen.",
            shelflife: "6 Monate nach dem Öffnen.",
            usage: "Ideal zu gegrilltem Fleisch, in Marinaden oder als Dip.",
            wastereduction:
                "Übrig gebliebene BBQ-Sauce in Marinaden oder als Zutat für Eintöpfe verwenden."
        ),
        GroceryModel(
            name: "Teriyaki Sauce",
            description:
                "Teriyaki-Sauce ist eine japanische Marinade aus Sojasauce, Zucker, Reisessig und Gewürzen, die Gerichte süß und würzig macht.",
            storage: "Im Kühlschrank nach dem Öffnen.",
            shelflife: "6 Monate nach dem Öffnen.",
            usage:
                "Ideal zum Marinieren von Fleisch, Geflügel, Fisch oder als Dip.",
            wastereduction:
                "Übrig gebliebene Teriyaki-Sauce in Saucen oder für Pfannengerichte verwenden."
        ),
        GroceryModel(
            name: "Worcester Sauce",
            description:
                "Worcester Sauce ist eine englische Würzsauce, die durch einen einzigartigen Fermentierungsprozess aus Essig, Melasse, Sojasauce und Gewürzen hergestellt wird.",
            storage:
                "An einem kühlen, trockenen Ort, nach dem Öffnen im Kühlschrank.",
            shelflife: "1 Jahr nach dem Öffnen.",
            usage:
                "Ideal für Saucen, Marinaden oder als Würze in Fleischgerichten.",
            wastereduction:
                "Übrig gebliebene Worcester Sauce in Saucen oder Eintöpfen verwenden."
        ),
        GroceryModel(
            name: "Mayonnaise",
            description:
                "Mayonnaise ist eine cremige Sauce aus Eigelb, Öl und Essig oder Zitronensaft, die in vielen Gerichten als Basis dient.",
            storage: "Nach dem Öffnen im Kühlschrank.",
            shelflife: "2–3 Monate nach dem Öffnen.",
            usage: "Ideal für Sandwiches, als Dip oder in Salaten.",
            wastereduction:
                "Übrig gebliebene Mayonnaise kann in Dressings oder als Zutat für Dips verwendet werden."
        ),
        GroceryModel(
            name: "Hummus",
            description:
                "Hummus ist eine Paste aus pürierten Kichererbsen, Tahin, Olivenöl, Zitronensaft und Knoblauch. Es ist eine proteinreiche, pflanzliche Mahlzeit.",
            storage: "Im Kühlschrank.",
            shelflife: "5–7 Tage im Kühlschrank.",
            usage: "Ideal als Dip, auf Brot oder in Wraps.",
            wastereduction:
                "Übrig gebliebenen Hummus in Dressings oder als Sandwichaufstrich verwenden."
        ),
        GroceryModel(
            name: "Tahin",
            description:
                "Tahin ist eine Paste aus gemahlenen Sesamkörnern und hat einen milden, nussigen Geschmack. Es ist eine gute Quelle für gesunde Fette und Mineralstoffe.",
            storage: "An einem kühlen, trockenen Ort oder im Kühlschrank.",
            shelflife: "6 Monate.",
            usage: "Ideal in Hummus, Saucen, Dressings oder als Brotaufstrich.",
            wastereduction:
                "Übrig gebliebenes Tahin in Saucen, Dressings oder Smoothies verwenden."
        ),
        GroceryModel(
            name: "Erdnüsse",
            description:
                "Erdnüsse sind proteinreich, enthalten gesunde Fette und sind eine gute Quelle für Vitamin E und B-Vitamine.",
            storage:
                "An einem kühlen, trockenen Ort in einem luftdichten Behälter.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage:
                "Ideal als Snack, in Salaten, in Saucen oder als Zutat in Gebäck.",
            wastereduction:
                "Übrig gebliebene Erdnüsse in Dips, Currys oder als Snack verwenden."
        ),
        GroceryModel(
            name: "Walnüsse",
            description:
                "Walnüsse sind reich an Omega-3-Fettsäuren, Eiweiß und Ballaststoffen.",
            storage:
                "An einem kühlen, trockenen Ort, am besten im Kühlschrank.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage: "Ideal in Salaten, Gebäck oder als Snack.",
            wastereduction:
                "Übrig gebliebene Walnüsse in Müsli, Salaten oder als Zutat in Kuchen verwenden."
        ),
        GroceryModel(
            name: "Sonnenblumenkerne",
            description:
                "Sonnenblumenkerne sind nahrhaft und enthalten viele gesunde Fette, Vitamine und Mineralstoffe.",
            storage:
                "An einem kühlen, trockenen Ort, in einem luftdichten Behälter.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage: "Ideal in Salaten, als Snack oder in Müslis und Backwaren.",
            wastereduction:
                "Übrig gebliebene Sonnenblumenkerne in Granola, Müsli oder als Topping für Joghurt verwenden."
        ),
        GroceryModel(
            name: "Mandeln",
            description:
                "Mandeln sind reich an gesunden Fetten, Eiweiß und Ballaststoffen.",
            storage:
                "An einem kühlen, trockenen Ort, in einem luftdichten Behälter.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage: "Ideal als Snack, in Müsli, Backwaren oder in Saucen.",
            wastereduction:
                "Übrig gebliebene Mandeln in Gebäck oder als Zutat in Salaten verwenden."
        ),
        GroceryModel(
            name: "Paranüsse",
            description:
                "Paranüsse sind eine ausgezeichnete Quelle für Selen und gesunde Fette.",
            storage:
                "An einem kühlen, trockenen Ort, in einem luftdichten Behälter.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage: "Ideal als Snack, in Müsli oder in Salaten.",
            wastereduction:
                "Übrig gebliebene Paranüsse in Desserts oder als Zutat für energiereiche Snacks verwenden."
        ),

        GroceryModel(
            name: "Thunfisch Dose",
            description:
                "Thunfisch aus der Dose ist eine praktische und proteinreiche Zutat, die in vielen Gerichten verwendet werden kann. Er ist eine gute Quelle für Omega-3-Fettsäuren und Eiweiß.",
            storage:
                "An einem kühlen, trockenen Ort lagern. Nach dem Öffnen im Kühlschrank aufbewahren.",
            shelflife:
                "Ungeöffnet bis zu 2 Jahre haltbar, nach dem Öffnen 1–2 Tage im Kühlschrank.",
            usage:
                "Ideal für Salate, Sandwiches, Pasta, Aufläufe oder als Snack.",
            wastereduction:
                "Übrig gebliebenen Thunfisch in Salaten, Saucen oder Sandwiches verwenden."
        ),
        GroceryModel(
            name: "Dosentomaten",
            description:
                "Dosentomaten sind eine beliebte Zutat für Saucen, Eintöpfe und Suppen. Sie bieten den vollen Geschmack frischer Tomaten und sind oft reifer und intensiver im Geschmack.",
            storage:
                "An einem kühlen, trockenen Ort lagern. Nach dem Öffnen im Kühlschrank aufbewahren.",
            shelflife:
                "Ungeöffnet 1–2 Jahre haltbar, nach dem Öffnen 3–5 Tage im Kühlschrank.",
            usage:
                "Perfekt für Tomatensaucen, Suppen, Chili oder als Basis für viele Gerichte.",
            wastereduction:
                "Übrig gebliebene Dosentomaten können in Saucen, Suppen oder Eintöpfen verarbeitet werden."
        ),
        GroceryModel(
            name: "Eingelegte Gurken",
            description:
                "Eingelegte Gurken sind eine beliebte Beilage, die durch den Essig- und Gewürzprozess einen säuerlichen Geschmack erhalten. Sie sind kalorienarm und reich an Antioxidantien.",
            storage:
                "An einem kühlen, trockenen Ort lagern. Nach dem Öffnen im Kühlschrank aufbewahren.",
            shelflife:
                "Ungeöffnet 1–2 Jahre haltbar, nach dem Öffnen 2–3 Monate im Kühlschrank.",
            usage: "Ideal als Beilage zu Sandwiches, Salaten oder als Snack.",
            wastereduction:
                "Übrig gebliebene Gurken können in Salaten oder als Garnitur für verschiedene Gerichte verwendet werden."
        ),
        GroceryModel(
            name: "Eingelegte Maiskölbchen",
            description:
                "Eingelegte Maiskölbchen sind ein erfrischender Snack oder eine Beilage mit einer leicht süß-sauren Note.",
            storage:
                "An einem kühlen, trockenen Ort lagern. Nach dem Öffnen im Kühlschrank aufbewahren.",
            shelflife:
                "Ungeöffnet 1–2 Jahre haltbar, nach dem Öffnen 1–2 Wochen im Kühlschrank.",
            usage: "Perfekt für Salate, als Beilage oder in Antipasti-Platten.",
            wastereduction:
                "Übrig gebliebene Maiskölbchen können in Salaten oder als Snack verwendet werden."
        ),
        GroceryModel(
            name: "Dosenessen",
            description:
                "Dosenessen umfasst Fertiggerichte wie Eintöpfe, Chili oder andere schnell zubereitete Mahlzeiten, die in der Dose konserviert werden.",
            storage: "An einem kühlen, trockenen Ort lagern.",
            shelflife: "Ungeöffnet bis zu 2 Jahre haltbar.",
            usage: "Ideal als schnelle Mahlzeit oder für Notfälle.",
            wastereduction:
                "Übrig gebliebenes Dosenessen kann in Aufläufen oder als Füllung für Wraps verwendet werden."
        ),
        GroceryModel(
            name: "Tiefkühlpizza",
            description:
                "Tiefkühlpizza ist eine schnelle und praktische Mahlzeit, die in vielen Varianten erhältlich ist. Sie enthält häufig Käse, Tomaten und verschiedene Beläge.",
            storage: "Im Gefrierfach lagern.",
            shelflife: "Ungeöffnet 6–12 Monate im Gefrierfach haltbar.",
            usage: "Ideal für eine schnelle Mahlzeit oder als Snack.",
            wastereduction:
                "Übrig gebliebene Pizza kann für eine schnelle Mahlzeit oder als Snack wieder aufgewärmt werden."
        ),
        GroceryModel(
            name: "Fertigsuppen",
            description:
                "Fertigsuppen aus der Dose oder im Glas bieten eine schnelle und einfache Lösung für eine Mahlzeit. Sie sind in vielen verschiedenen Varianten erhältlich, wie z. B. Tomatensuppe, Hühnersuppe oder Gemüsesuppe.",
            storage:
                "An einem kühlen, trockenen Ort lagern. Nach dem Öffnen im Kühlschrank aufbewahren.",
            shelflife:
                "Ungeöffnet 1–2 Jahre haltbar, nach dem Öffnen 3–5 Tage im Kühlschrank.",
            usage: "Ideal als schnelle Mahlzeit oder als Basis für eine Suppe.",
            wastereduction:
                "Übrig gebliebene Suppe kann in Saucen oder als Basis für Eintöpfe verwendet werden."
        ),
        GroceryModel(
            name: "Sonnenblumenöl",
            description:
                "Sonnenblumenöl ist ein neutrales, pflanzliches Öl, das reich an mehrfach ungesättigten Fettsäuren ist. Es wird häufig zum Braten, Frittieren und in Dressings verwendet.",
            storage: "An einem kühlen, trockenen Ort, vor Licht geschützt.",
            shelflife: "1 Jahr, nach dem Öffnen 6 Monate.",
            usage: "Ideal zum Braten, Frittieren oder für Salatdressings.",
            wastereduction:
                "Übrig gebliebenes Sonnenblumenöl kann zum Kochen von Gemüse oder als Basis für Marinaden verwendet werden."
        ),
        GroceryModel(
            name: "Olivenöl",
            description:
                "Olivenöl ist ein gesundes pflanzliches Öl, das reich an einfach ungesättigten Fettsäuren und Antioxidantien ist. Es wird häufig in der mediterranen Küche verwendet.",
            storage: "An einem kühlen, dunklen Ort, vor Licht geschützt.",
            shelflife: "1 Jahr, nach dem Öffnen 6 Monate.",
            usage:
                "Ideal zum Braten, für Salatdressings oder zum Verfeinern von Gerichten.",
            wastereduction:
                "Übrig gebliebenes Olivenöl kann in Saucen, Marinaden oder als Dip für Brot verwendet werden."
        ),
        GroceryModel(
            name: "Rapsöl",
            description:
                "Rapsöl ist ein vielseitiges pflanzliches Öl mit einem milden Geschmack, das reich an Omega-3-Fettsäuren ist. Es eignet sich hervorragend zum Braten, Frittieren und Backen.",
            storage: "An einem kühlen, trockenen Ort, vor Licht geschützt.",
            shelflife: "1 Jahr, nach dem Öffnen 6 Monate.",
            usage:
                "Ideal für das Braten, Backen oder als Basis für Salatdressings.",
            wastereduction:
                "Übrig gebliebenes Rapsöl kann in Saucen, zum Schmoren von Gemüse oder als Zutat in Teigen verwendet werden."
        ),
        GroceryModel(
            name: "Schokolade",
            description:
                "Schokolade ist ein süßer Genuss, der aus Kakaobohnen hergestellt wird. Sie ist in vielen Variationen erhältlich, z. B. Zartbitter, Vollmilch oder weiß.",
            storage:
                "An einem kühlen, trockenen Ort, idealerweise bei einer Temperatur unter 20°C.",
            shelflife: "6 Monate bis 1 Jahr, je nach Art und Lagerung.",
            usage: "Ideal als Snack, in Gebäck oder als Zutat in Desserts.",
            wastereduction:
                "Übrig gebliebene Schokolade kann in Kuchen oder als Topping für Desserts verwendet werden."
        ),
        GroceryModel(
            name: "Gummibärchen",
            description:
                "Gummibärchen sind süße, fruchtige Süßigkeiten, die aus Zucker, Gelatine und Fruchtsäften bestehen.",
            storage:
                "An einem kühlen, trockenen Ort, vor Feuchtigkeit geschützt.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage: "Ideal als Snack oder in kleinen Mengen als Süßigkeit.",
            wastereduction:
                "Übrig gebliebene Gummibärchen können in Torten oder als Dekoration für Desserts verwendet werden."
        ),
        GroceryModel(
            name: "Chips",
            description:
                "Chips sind knusprige Snacks, die aus dünn geschnittenen Kartoffelscheiben hergestellt werden und oft gesalzen oder gewürzt sind.",
            storage:
                "An einem kühlen, trockenen Ort, in der Originalverpackung.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage:
                "Ideal als Snack oder in Kombination mit Dips und Sandwiches.",
            wastereduction:
                "Übrig gebliebene Chips können zu Krümeln verarbeitet und in Panaden oder als Topping für Salate verwendet werden."
        ),
        GroceryModel(
            name: "Salzstangen",
            description:
                "Salzstangen sind knusprige Snacks, die aus Teig hergestellt und mit Salz bestreut werden.",
            storage:
                "An einem kühlen, trockenen Ort, in der Originalverpackung.",
            shelflife: "6 Monate bis 1 Jahr.",
            usage:
                "Ideal als Snack oder in Kombination mit Dips und anderen Snacks.",
            wastereduction:
                "Übrig gebliebene Salzstangen können in Salaten oder als Topping für Suppe verwendet werden."
        ),
    ]

    func addGrocery() {

        Task {
            do {
                for grocery in groceryList {
                    try await addG(grocery)
                }
                print("Erfolgreich Liste hochgeladen")
            } catch {
                print(error)
            }
        }
    }

    func addG(_ grocery: GroceryModel) async throws {
        _ = try fb.database
            .collection("groceryaz")
            .addDocument(from: grocery)
    }
}
