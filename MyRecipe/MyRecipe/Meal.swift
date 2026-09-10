
import Foundation
import SwiftUI

struct MealResponse: Codable {
    let meals: [Meal]?
}

struct Meal: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let thumbnailURL: String
    let instructions: String

    let ingredient1: String?
    let ingredient2: String?
    let ingredient3: String?
    let ingredient4: String?
    let ingredient5: String?
    let ingredient6: String?
    let ingredient7: String?
    let ingredient8: String?

    let measure1: String?
    let measure2: String?
    let measure3: String?
    let measure4: String?
    let measure5: String?
    let measure6: String?
    let measure7: String?
    let measure8: String?

  
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case thumbnailURL = "strMealThumb"
        case instructions = "strInstructions"
        case ingredient1 = "strIngredient1"
        case ingredient2 = "strIngredient2"
        case ingredient3 = "strIngredient3"
        case ingredient4 = "strIngredient4"
        case ingredient5 = "strIngredient5"
        case ingredient6 = "strIngredient6"
        case ingredient7 = "strIngredient7"
        case ingredient8 = "strIngredient8"
        case measure1 = "strMeasure1"
        case measure2 = "strMeasure2"
        case measure3 = "strMeasure3"
        case measure4 = "strMeasure4"
        case measure5 = "strMeasure5"
        case measure6 = "strMeasure6"
        case measure7 = "strMeasure7"
        case measure8 = "strMeasure8"
    }

    
    var ingredientsList: [String] {
        let pairs: [(String?, String?)] = [
            (ingredient1, measure1), (ingredient2, measure2),
            (ingredient3, measure3), (ingredient4, measure4),
            (ingredient5, measure5), (ingredient6, measure6),
            (ingredient7, measure7), (ingredient8, measure8)
        ]
        return pairs.compactMap { ingredient, measure in
            guard let ingredient,!ingredient.trimmingCharacters(in: .whitespaces).isEmpty else {
                return nil
            }
            let measureText = measure?.trimmingCharacters(in: .whitespaces) ?? ""
            return measureText.isEmpty ? ingredient : "\(measureText) \(ingredient)"
        }
    }
}
