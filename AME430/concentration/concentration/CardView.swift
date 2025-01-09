//
//  CardView.swift
//  concentration
//
//  Created by Bjorn Bradley on 9/19/24.
//

import SwiftUI

typealias Card = PairsGame.Card

struct CardView: View, Animatable {
    let card: Card

    var rotation: Double
    
    let cornerRadius = 12.0
    let lineWidth = 2.0
    let largest = 60.0
    let smallest = 10.0
    
    var body: some View {
        ZStack {
            if card.isFaceUp || !card.isMatched {
                let base = RoundedRectangle(cornerRadius: cornerRadius)
                base.fill(.white)
                if isFaceUp {
                    cardContents
                } else {
                    cardBack
                }
                base.strokeBorder(lineWidth: lineWidth)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .opacity(0)  // Keep position but make invisible
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
        .transition(.scale)
        .shadow(color: .blue, radius: 4, x: 4, y: 4)
        .frame(width: 100, height: 150)
    }

    var isFaceUp: Bool {
        rotation < 90
    }

    var animatableData: Double {
        get { return rotation }
        set { rotation = newValue }
    }

    init(card: Card) {
        self.card = card
        rotation = card.isFaceUp ? 0 : 180
    }

    @ViewBuilder var cardContents: some View {
        let minScaleFactor = smallest / largest
        Text(card.content)
            .font(.system(size: largest))
            .minimumScaleFactor(minScaleFactor)
    }

    @ViewBuilder var cardBack: some View {
        let minScaleFactor = smallest / largest
        Text("❓")
            .font(.system(size: largest))
            .minimumScaleFactor(minScaleFactor)
            .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
    }
}
