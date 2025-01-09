//
//  PairsGameViewModel.swift
//  concentration
//
//  Created by Bjorn Bradley on 9/11/24.
//
import Foundation
import SwiftUI

class PairsGameViewModel: ObservableObject {
    typealias Card = PairsGame.Card

    @Published private var game = PairsGame()

    @Published var score = 0 // Player's score
    @Published var selectedTheme = "Fruits" // Default theme

    private var indexOfFirstSelectedCard: Int? = nil

    var themes: [String: [String]] = [
        "Fruits": ["🍎", "🍊", "🍌", "🍑", "🥝", "🍇", "🫐", "🍒"],
        "Animals": ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼"],
        "Objects": ["🚗", "✈️", "🚀", "🚤", "🛸", "🚁", "🛶", "🛳️"]
    ]

    var cards: [Card] {
        game.cards
    }

    var unmatchedCount: Int {
        return cards.filter { !$0.isMatched }.count
    }

    init() {
        reset()
    }

    func reset() {
        game = PairsGame(numberOfPairsOfCards: themes[selectedTheme]?.count ?? 8, cardContentFactory: { index in
            return themes[selectedTheme]?[index] ?? "❓"
        })
        score = 0 // Reset score
        indexOfFirstSelectedCard = nil // Reset first selected card tracker
    }

    func choose(card: Card) {
        // Find the index of the selected card
        if let chosenIndex = self.game.cards.firstIndex(where: { $0.id == card.id }),
           !self.game.cards[chosenIndex].isFaceUp, !self.game.cards[chosenIndex].isMatched {
            // If no card is currently selected
            if let potentialMatchIndex = self.indexOfFirstSelectedCard {
                // Two cards have been selected, check for match
                self.game.cards[chosenIndex].isFaceUp = true

                if self.game.cards[potentialMatchIndex].content == self.game.cards[chosenIndex].content {
                    // It's a match, mark both cards as matched
                    self.game.cards[potentialMatchIndex].isMatched = true
                    self.game.cards[chosenIndex].isMatched = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.game.cards[potentialMatchIndex].isFaceUp = false
                        self.game.cards[chosenIndex].isFaceUp = false
                    }
                    
                    self.score += 1
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.game.cards[potentialMatchIndex].isFaceUp = false
                        self.game.cards[chosenIndex].isFaceUp = false
                    }
                }
                self.indexOfFirstSelectedCard = nil
            } else {
                self.game.cards[chosenIndex].isFaceUp = true
                self.indexOfFirstSelectedCard = chosenIndex
            }
        }
    }


    func shuffle() {
        game.shuffle()
    }
}

