import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case badResponse
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "That URL was invalid."
        case .badResponse: return "The server didn't respond correctly."
        case .decodingFailed: return "Couldn't understand the data we got back."
        }
    }
}

struct RecipeService {

    private let baseURL = "https://www.themealdb.com/api/json/v1/1"

   
    func searchMeals(query: String) async throws -> [Meal] {
       
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/search.php?s=\(encodedQuery)") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }

        do {
            let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
            return decoded.meals ?? []
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func fetchMeal(id: String) async throws -> Meal? {
        guard let url = URL(string: "\(baseURL)/lookup.php?i=\(id)") else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }
        let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
        return decoded.meals?.first
    }

    func fetchFeatured() async throws -> [Meal] {
        let seedQueries = ["chicken", "beef", "mutton", "salad", "pasta", "cake"]

   
        async let chicken = searchMeals(query: seedQueries[0])
        async let beef = searchMeals(query: seedQueries[1])
        async let mutton = searchMeals(query: seedQueries[2])
        async let salad = searchMeals(query: seedQueries[3])
        async let pasta = searchMeals(query: seedQueries[4])
        async let cake = searchMeals(query: seedQueries[5])

        let allResults = try await [chicken, beef, mutton, salad, pasta, cake]
            .flatMap { $0 }

        var seenIDs = Set<String>()
        let uniqueMeals = allResults.filter { meal in
            seenIDs.insert(meal.id).inserted
        }

        return uniqueMeals.shuffled()
    }
}
