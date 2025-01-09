//
//  recommendationView.swift
//  Json Assignment
//
//  Created by Bjorn Bradley on 10/24/24.
//

import Foundation
import SwiftUI

struct RecommendationView: View {
    @StateObject private var viewModel = RecommendationViewModel()
    @State private var searchText: String = ""

    var body: some View {
        VStack {
            // Search bar
            TextField("Search for a song...", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { newValue in
                    viewModel.fetchRecommendations(searchTerm: newValue)
                }

            // List of recommendations
            if !viewModel.recommendations.isEmpty {
                List(viewModel.recommendations) { recommendation in
                    Text(recommendation.title)
                }
            } else {
                Text("No recommendations yet")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .navigationTitle("Test Recommendations")
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationView()
    }
}
