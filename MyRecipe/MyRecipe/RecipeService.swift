import Foundation

// MARK: - Service (the "API calling" layer)
// This is the ONLY place that knows about URLs, URLSession, and JSON.
// The ViewModel calls this; the View never talks to it directly.

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

    /// Search meals by name, e.g. "chicken", "pasta"
    func searchMeals(query: String) async throws -> [Meal] {
        // 1. Build the URL safely (percent-encode the search text)
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "\(baseURL)/search.php?s=\(encodedQuery)") else {
            throw NetworkError.invalidURL
        }

        // 2. Make the request. `await` pauses here without blocking the UI thread.
        let (data, response) = try await URLSession.shared.data(from: url)

        // 3. Check we got a real HTTP 200 back.
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }

        // 4. Decode the raw JSON `Data` into our Swift Meal structs.
        do {
            let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
            return decoded.meals ?? []
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    /// Fetch a single meal's full detail by id (used e.g. for refreshing a saved favorite)
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

    /// Fetch a *varied* home-screen feed instead of just one dish type.
    /// We ask for several different searches at once (concurrently, not one
    /// after another) and merge the results into one mixed list — so the
    /// home screen shows chicken, beef, mutton, salad, etc. together instead
    /// of only whichever single word we searched for.
    func fetchFeatured() async throws -> [Meal] {
        let seedQueries = ["chicken", "beef", "mutton", "salad", "pasta", "cake"]

        // `async let` runs all these network calls in parallel instead of
        // waiting for each one to finish before starting the next — much
        // faster than doing them one at a time in a loop.
        async let chicken = searchMeals(query: seedQueries[0])
        async let beef = searchMeals(query: seedQueries[1])
        async let mutton = searchMeals(query: seedQueries[2])
        async let salad = searchMeals(query: seedQueries[3])
        async let pasta = searchMeals(query: seedQueries[4])
        async let cake = searchMeals(query: seedQueries[5])

        // `try await` here collects all six results once every one has
        // finished. If one search fails/returns empty, the others still work.
        let allResults = try await [chicken, beef, mutton, salad, pasta, cake]
            .flatMap { $0 }

        // Some meals could theoretically show up in more than one search —
        // dedupe by id so nothing appears twice on the home screen.
        var seenIDs = Set<String>()
        let uniqueMeals = allResults.filter { meal in
            seenIDs.insert(meal.id).inserted
        }

        return uniqueMeals.shuffled()
    }
}
