//
//  RecipeDetailView.swift
//  MyRecipe
//
//  Created by Sakib on 2026-08-22.
//

import Foundation
import SwiftUI

// A simple screen like this doesn't need its own ViewModel — it just
// displays data it was handed. Not every View needs a ViewModel;
// add one only when a screen has its own logic/state to manage
// (loading, editing, favoriting, etc).

struct RecipeDetailView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: meal.thumbnailURL)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    Text(meal.name)
                        .font(.title2)
                        .bold()

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ingredients")
                            .font(.headline)
                        ForEach(meal.ingredientsList, id: \.self) { item in
                            Text("• \(item)")
                                .font(.subheadline)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Instructions")
                            .font(.headline)
                        Text(meal.instructions)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(meal.name)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }
}
