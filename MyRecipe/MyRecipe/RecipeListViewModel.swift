import Foundation

// MARK: - ViewModel
// Owns UI state (loading, error, results) and talks to the Service.
// The View reads these properties and calls these methods —
// it never fetches data itself.
//
// @Observable (Swift's modern Observation framework, iOS 17+) makes
// SwiftUI automatically re-render any View that reads a changed property.
// No @Published, no Combine needed.

@Observable
class RecipeListViewModel {

    // MARK: Published-ish state (View reads these directly)
    var meals: [Meal] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: Dependencies
    // Injected so you can swap in a fake service for previews/tests.
    private let service: RecipeService

    init(service: RecipeService = RecipeService()) {
        self.service = service
    }

    // MARK: Actions (called from the View, e.g. inside .task or a Button)

    /// Called once when the screen first appears (and when the search bar
    /// is cleared) — loads a mixed variety of recipes instead of just one type.
    @MainActor
    func loadFeed() async {
        isLoading = true
        errorMessage = nil

        do {
            meals = try await service.fetchFeatured()
            if meals.isEmpty {
                errorMessage = "Couldn't load recipes right now."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Called when the user actually types something and searches —
    /// this replaces the mixed feed with results matching their query.
    @MainActor
    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            // Search bar was cleared — go back to showing the varied feed.
            await loadFeed()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            meals = try await service.searchMeals(query: trimmed)
            if meals.isEmpty {
                errorMessage = "No recipes found for \"\(trimmed)\"."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
