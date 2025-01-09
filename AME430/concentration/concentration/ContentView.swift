//
//  ContentView.swift
//  concentration
//
//  Created by Bjorn Bradley on 9/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameViewModel: PairsGameViewModel
    @State private var showGameOver = false

    // Define the number of columns for the grid
    let columns = [
        GridItem(.adaptive(minimum: 80)) // Minimum size for a card
    ]

    var body: some View {
        VStack {
            // Game Title
            Text("Concentration Game")
                .font(.largeTitle)
                .padding()

            // Score display
            Text("Score: \(gameViewModel.score)") // Display score
                .font(.title2)
                .padding()

            // Cards grid layout
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(gameViewModel.cards) { card in
                    if card.isMatched {
                        // Make matched cards invisible, but keep their position
                        Color.clear
                            .frame(width: 100, height: 150) // Keep the card size consistent
                    } else {
                        CardView(card: card)
                            .onTapGesture {
                                gameViewModel.choose(card: card)
                            }
                            .padding(10) // Add slight padding between the cards
                    }
                }
            }
            .padding()

            // Theme Picker
            Picker("Select Theme", selection: $gameViewModel.selectedTheme) { // Two-way binding with $ sign
                ForEach(gameViewModel.themes.keys.sorted(), id: \.self) { theme in
                    Text(theme)
                }
            }
            .onChange(of: gameViewModel.selectedTheme) { _ in
                gameViewModel.reset() // Reset the game when the theme changes
            }
            .padding()
        }
    }
}

