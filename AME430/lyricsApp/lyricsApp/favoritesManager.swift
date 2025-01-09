//
//  favoritesManager.swift
//  lyricsApp
//
//  Created by Bjorn Bradley on 10/28/24.
//

import Foundation
import SwiftUI

struct FavoriteSong: Hashable {
    let title: String
}

class FavoriteManager: ObservableObject {
    @Published private(set) var favoritedSongs: Set<FavoriteSong> = []

    // Add song to favorites
    func addFavorite(songTitle: String) {
        let newFavorite = FavoriteSong(title: songTitle)
        favoritedSongs.insert(newFavorite)
    }

    // Remove song from favorites
    func removeFavorite(songTitle: String) {
        let favoriteToRemove = FavoriteSong(title: songTitle)
        favoritedSongs.remove(favoriteToRemove)
    }

    // Check if song is favorited
    func isFavorite(songTitle: String) -> Bool {
        return favoritedSongs.contains(FavoriteSong(title: songTitle))
    }

    // Toggle favorite status
    func toggleFavorite(songTitle: String) {
        if isFavorite(songTitle: songTitle) {
            removeFavorite(songTitle: songTitle)
        } else {
            addFavorite(songTitle: songTitle)
        }
    }
}
