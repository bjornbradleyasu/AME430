//
//  LyricsViewModel.swift
//  Json Assignment
//
//  Created by Bjorn Bradley on 10/17/24.
//

import Foundation
import SwiftUI

class LyricsViewModel: ObservableObject {
    @Published var lyrics: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    func fetchLyrics(searchTerm: String) {
        // Split search term into artist and song title
        let components = searchTerm.split(separator: "-")
        guard components.count == 2 else {
            DispatchQueue.main.async {
                            self.errorMessage = "Please enter in the format: Song - Artist"
                        }
                        return
                    }
        
        let artist = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let song = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !artist.isEmpty, !song.isEmpty else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Please enter both Song and Artist"
                    }
                    return
                }
        
        let urlString = "https://api.lyrics.ovh/v1/\(artist)/\(song)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: urlString ?? "") else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid URL"
                    }
                    return
                }
        self.isLoading = true

        // Fetch lyrics from the API
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error fetching lyrics: \(error.localizedDescription)"
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
                let result = try JSONDecoder().decode(LyricsResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.lyrics = result.lyrics
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to decode lyrics"
                }
            }
        }.resume()
    }
}

struct LyricsResponse: Codable {
    let lyrics: String
}



