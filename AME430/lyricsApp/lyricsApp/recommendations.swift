//
//  recommendations.swift
//  Json Assignment
//
//  Created by Bjorn Bradley on 10/24/24.
//

import Foundation
import SwiftUI
import Combine

class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var errorMessage: String? = nil

    // Fetch top 10 recommendations based on the search
    func fetchRecommendations(searchTerm: String) {
        guard !searchTerm.isEmpty else {
                    DispatchQueue.main.async {
                        self.recommendations = []
                    }
                    return
                }

        let urlString = "https://api.lyrics.ovh/suggest/\(searchTerm)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                guard let url = URL(string: urlString ?? "") else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid URL"
                    }
                    return
                }

                // Fetch recommendations from the API
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.errorMessage = "Error fetching recommendations: \(error.localizedDescription)"
                        }
                        return
                    }

                    guard let data = data else {
                        DispatchQueue.main.async {
                            self?.errorMessage = "No data received"
                        }
                        return
                    }

                    do {
                        // Decode the JSON response
                        let result = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                        DispatchQueue.main.async {
                            self?.recommendations = result.data.map { Recommendation(title: "\($0.title) - \($0.artist.name)") }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self?.errorMessage = "Failed to decode recommendations"
                        }
                    }
                }.resume()
            }
        }

        struct RecommendationResponse: Codable {
            let data: [SongSuggestion]
        }

        struct SongSuggestion: Codable {
            let title: String
            let artist: Artist
        }

        struct Artist: Codable {
            let name: String
        }

        struct Recommendation: Identifiable {
            let id = UUID()
            let title: String
        }

