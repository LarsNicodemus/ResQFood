//
//  MealDBViewModel.swift
//  ResQFood
//
//  Created by Lars Nicodemus on 02.01.25.
//

import SwiftUI

@MainActor
class MealDBViewModel: ObservableObject {
    let mealRepository: MealDBRepository = MealDBRepositoryImplementation()
    @Published var meals: [Meal] = []
    @Published var ingredient = ""
    @Published var mealDetail: Bool = false
    @Published var selectedMeal: String = ""
    @Published var selectedRecipe: DetailedMeal?
    @Published var ingredients: [String] = []
    @Published var measures: [String] = []

    /// Sucht nach Rezepten basierend auf einer Zutat.
    /// - Uses `translateIngredient` um die Zutat zu übersetzen.
    /// - Updates: `meals` mit den abgerufenen Mahlzeiten.
    /// - Prints: Fehlermeldungen, wenn die Rezepte nicht abgerufen werden können.
    func searchRecipies() {
        translateIngredient(ingredient) { translatedIngredient in
            Task {
                do {
                    guard
                        let retrievedMeals = try await self.mealRepository
                            .searchRecipe(translatedIngredient)
                    else { return }
                    DispatchQueue.main.async {
                                        self.meals = retrievedMeals
                                    }
                } catch {
                    print("Error retrieving recipes: \(error)")
                }
            }
        }
    }
    
    /// Ruft die Details eines ausgewählten Rezepts ab.
    /// - Updates: `selectedRecipe` mit den abgerufenen Rezeptdetails.
    /// - Prints: Fehlermeldungen, wenn die Rezeptdetails nicht abgerufen werden können.
    func getRecipeDetails() {
        Task {
            do {
                guard
                    let recipeDetails = try await self.mealRepository
                        .getRecipeDetails(idMeal: selectedMeal)
                else { return }
                self.selectedRecipe = recipeDetails
            } catch {
                print("Error retrieving recipe: \(error)")
            }
        }
    }

    /// Übersetzt eine Zutat in eine andere Sprache.
    /// - Parameters:
    ///   - ingredient: Die zu übersetzende Zutat.
    ///   - completion: Callback mit der übersetzten Zutat.
    private func translateIngredient(
        _ ingredient: String, completion: @escaping (String) -> Void
    ) {

        let translated = translations[ingredient] ?? ingredient
        completion(translated)
    }

    let translations = [
        "Tomate": "Tomato",
        "Kartoffel": "Potato",
        "Zwiebel": "Onion",
        "Karotte": "Carrot",
        "Paprika": "Pepper",
        "Gurke": "Cucumber",
        "Salat": "Lettuce",
        "Spinat": "Spinach",
        "Brokkoli": "Broccoli",
        "Erbse": "Pea",
        "Mais": "Corn",
        "Kürbis": "Pumpkin",
        "Pilz": "Mushroom",
        "Kohl": "Cabbage",
        "Blumenkohl": "Cauliflower",
        "Bohne": "Bean",
        "Lauch": "Leek",
        "Zucchini": "Zucchini",
        "Avocado": "Avocado",
        "Apfel": "Apple",
        "Banane": "Banana",
        "Birne": "Pear",
        "Orange": "Orange",
        "Zitrone": "Lemon",
        "Traube": "Grape",
        "Erdbeere": "Strawberry",
        "Kirsche": "Cherry",
        "Pflaume": "Plum",
        "Ananas": "Pineapple",
        "Mango": "Mango",
        "Kiwi": "Kiwi",
        "Brombeere": "Blackberry",
        "Himbeere": "Raspberry",
        "Johannisbeere": "Currant",
        "Granatapfel": "Pomegranate",
        "Dattel": "Date",
        "Feige": "Fig",
        "Melone": "Melon",
        "Wassermelone": "Watermelon",
        "Kokosnuss": "Coconut",
        "Nuss": "Nut",
        "Mandel": "Almond",
        "Haselnuss": "Hazelnut",
        "Walnuss": "Walnut",
        "Cashew": "Cashew",
        "Pistazie": "Pistachio",
        "Sesam": "Sesame",
        "Leinsamen": "Flaxseed",
        "Chia": "Chia",
        "Soja": "Soy",
        "Reis": "Rice",
        "Pasta": "Pasta",
        "Nudeln": "Noodles",
        "Linsen": "Lentils",
        "Quinoa": "Quinoa",
        "Bulgur": "Bulgur",
        "Couscous": "Couscous",
        "Gerste": "Barley",
        "Hafer": "Oats",
        "Weizen": "Wheat",
        "Roggen": "Rye",
        "Hirse": "Millet",
        "Kichererbse": "Chickpea",
        "Fisch": "Fish",
        "Lachs": "Salmon",
        "Thunfisch": "Tuna",
        "Makrele": "Mackerel",
        "Sardine": "Sardine",
        "Scholle": "Sole",
        "Hecht": "Pike",
        "Garnelen": "Shrimp",
        "Krabbe": "Crab",
        "Austern": "Oysters",
        "Hummer": "Lobster",
        "Muschel": "Mussel",
        "Rindfleisch": "Beef",
        "Rind": "Beef",
        "Fleisch" : "meat",
        "Schweinefleisch": "Pork",
        "Schwein": "Pork",
        "Hähnchen": "Chicken",
        "Huhn": "Chicken",
        "Hühnchen": "Chicken",
        "Pute": "Turkey",
        "Lamm": "Lamb",
        "Wurst": "Sausage",
        "Speck": "Bacon",
        "Schinken": "Ham",
        "Käse": "Cheese",
        "Mozzarella": "Mozzarella",
        "Cheddar": "Cheddar",
        "Parmesan": "Parmesan",
        "Feta": "Feta",
        "Ricotta": "Ricotta",
        "Quark": "Cottage cheese",
        "Joghurt": "Yogurt",
        "Milch": "Milk",
        "Butter": "Butter",
        "Eier": "Eggs",
        "Sahne": "Cream",
        "Öl": "Oil",
        "Olivenöl": "Olive oil",
        "Rapsöl": "Rapeseed oil",
        "Kokosöl": "Coconut oil",
        "Essig": "Vinegar",
        "Balsamico": "Balsamic vinegar",
        "Weinessig": "Wine vinegar",
        "Apfelessig": "Apple cider vinegar",
        "Senf": "Mustard",
        "Ketchup": "Ketchup",
        "Mayo": "Mayonnaise",
        "Tomatenmark": "Tomato paste",
        "Worcestershiresauce": "Worcestershire sauce",
        "Chili": "Chili",
        "Pfeffer": "Pepper",
        "Salz": "Salt",
        "Zucker": "Sugar",
        "Honig": "Honey",
        "Ahornsirup": "Maple syrup",
        "Vanille": "Vanilla",
        "Zimt": "Cinnamon",
        "Nelke": "Clove",
        "Muskatnuss": "Nutmeg",
        "Piment": "Allspice",
        "Ingwer": "Ginger",
        "Kurkuma": "Turmeric",
        "Kreuzkümmel": "Cumin",
        "Koriander": "Coriander",
        "Basilikum": "Basil",
        "Petersilie": "Parsley",
        "Rosmarin": "Rosemary",
        "Thymian": "Thyme",
        "Oregano": "Oregano",
        "Lorbeerblatt": "Bay leaf",
        "Salbei": "Sage",
        "Majoran": "Marjoram",
        "Dill": "Dill",
        "Estragon": "Tarragon",
        "Minze": "Mint",
        "Saffran": "Saffron",
        "Safran": "Saffron",
        "Tapioka": "Tapioca",
        "Agar-Agar": "Agar-agar",
        "Gelatine": "Gelatin",
        "Fischsoße": "Fish sauce",
        "Sojasoße": "Soy sauce",
        "Brühe": "Broth",
        "Gemüsebrühe": "Vegetable broth",
        "Hühnerbrühe": "Chicken broth",
        "Rinderbrühe": "Beef broth",
        "Suppen": "Soups",
        "Eintopf": "Stew",
        "Frittieren": "Fry",
        "Grillen": "Grill",
        "Backen": "Bake",
        "Kochen": "Cook",
        "Dämpfen": "Steam",
        "Rösten": "Roast",
        "Pürieren": "Puree",
        "Schneiden": "Cut",
        "Hackfleisch": "Minced meat",
        "Filet": "Filet",
        "Steak": "Steak",
        "Braten": "Roast",
        "Fenchel": "Fennel",
        "Spargel": "Asparagus",
        "Runkelrübe": "Turnip",
        "Rote Bete": "Beetroot",
        "Sellerie": "Celery",
        "Pak Choi": "Pak Choi",
        "Mangold": "Chard",
        "Wurzelpetersilie": "Parsnip",
        "Topinambur": "Jerusalem artichoke",
        "Amaranth": "Amaranth",
        "Buchweizen": "Buckwheat",
        "Pinienkerne": "Pine nuts",
        "Macadamianuss": "Macadamia nut",
        "Paranuss": "Brazil nut",
        "Kümmel": "Caraway",
        "Tofu": "Tofu",
        "Tempeh": "Tempeh",
        "Seitan": "Seitan",
        "Hefe": "Yeast",
        "Backpulver": "Baking powder",
        "Natron": "Baking soda",
        "Mehl": "Flour",
        "Vollkornmehl": "Whole wheat flour",
        "Stärke": "Starch",
        "Maisstärke": "Cornstarch",
        "Grieß": "Semolina",
        "Meeresfrüchte": "Seafood",
        "Kaninchen": "Rabbit",
        "Ente": "Duck",
        "Gans": "Goose",
        "Wild": "Game",
        "Leberwurst": "Liver sausage",
        "Frischkäse": "Cream cheese",
        "Schmelzkäse": "Processed cheese",
        "Schmand": "Sour cream",
        "Sauerrahm": "Sour cream",
        "Kondensmilch": "Condensed milk",
        "Kardamom": "Cardamom",
        "Sternanis": "Star anise",
        "Lorbeer": "Bay leaf",
        "Kerbel": "Chervil",
        "Anis": "Anise",
        "Curry": "Curry",
        "Safranfäden": "Saffron threads",
        "Wasabi": "Wasabi",
        "Miso": "Miso",
        "Teriyaki": "Teriyaki",
        "Sriracha": "Sriracha",
        "Tahini": "Tahini",
        "Harissa": "Harissa",
        "Gochujang": "Gochujang",
        "Weißwein": "White wine",
        "Rotwein": "Red wine",
        "Cognac": "Cognac",
        "Brandy": "Brandy",
        "Sherry": "Sherry",
        "Portwein": "Port wine",
        "Paniermehl": "Breadcrumbs",
        "Semmelbrösel": "Breadcrumbs",
        "Vanillezucker": "Vanilla sugar",
        "Puderzucker": "Powdered sugar",
        "Rohrzucker": "Cane sugar",
        "Instantkaffee": "Instant coffee",
        "Kakaopulver": "Cocoa powder",
        "Blockschokolade": "Cooking chocolate",
        "Marinieren": "Marinate",
        "Würzen": "Season",
        "Einlegen": "Pickle",
        "Kneten": "Knead",
        "Durchsieben": "Sift",
        "Aufschlagen": "Whisk",
        "Unterheben": "Fold in",
        "Pfanne": "Pan",
        "Topf": "Pot",
        "Backblech": "Baking sheet",
        "Auflaufform": "Casserole dish",
        "Springform": "Springform pan",
        "Sieb": "Sieve",
        "Schneebesen": "Whisk",
    ]
}
