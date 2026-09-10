import Foundation


@Observable
class RecipeListViewModel {

    var meals: [Meal] = []
    var isLoading = false
    var errorMessage: String?

    private let service: RecipeService

    init(service: RecipeService = RecipeService()) {
        self.service = service
    }

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

    @MainActor
    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            
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
