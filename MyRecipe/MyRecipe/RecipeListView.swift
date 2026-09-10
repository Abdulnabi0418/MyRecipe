import SwiftUI

struct RecipeListView: View {
    @State private var viewModel = RecipeListViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Recipes")
                .searchable(text: $searchText, prompt: "Search recipes")
                .onSubmit(of: .search) {
                    Task { await viewModel.search(query: searchText) }
                }
              
                .onChange(of: searchText) { _, newValue in
                    if newValue.isEmpty {
                        Task { await viewModel.loadFeed() }
                    }
                }
                .navigationDestination(for: Meal.self) { meal in
                    RecipeDetailView(meal: meal)
                }
        }
       
        .task {
            await viewModel.loadFeed()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading recipes...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                errorMessage,
                systemImage: "exclamationmark.triangle"
            )
        } else {
            List(viewModel.meals) { meal in
                NavigationLink(value: meal) {
                    RecipeRow(meal: meal)
                }
            }
            .listStyle(.plain)
        }
    }
}

private struct RecipeRow: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: meal.thumbnailURL)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(meal.name)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecipeListView()
}
