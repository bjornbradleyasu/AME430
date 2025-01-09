//
//  PairsGame.swift
//  concentration
//
//  Created by Bjorn Bradley on 9/11/24.
//

import Foundation

struct PairsGame {
    var cards: [Card]
    
    private var indexOfFirstCardPicked: Int? = nil {
            didSet {
                if indexOfFirstCardPicked == nil {
                    for index in cards.indices {
                        if !cards[index].isMatched {
                            cards[index].isFaceUp = false
                        }
                    }
                }
            }
        }
    
    
    init(numberOfPairsOfCards: Int = 2, cardContentFactory: (Int) -> String = { _ in "?" }) {
        cards = []
        for pairIndex in 0..<max(2, numberOfPairsOfCards) {
            let content = cardContentFactory(pairIndex)
            let id = UUID().uuidString
            cards.append(Card(content: content, id: id))
            cards.append(Card(content: content, id: UUID().uuidString))
        }
        cards.shuffle()
    }
    
    mutating func choose(card: Card) {
        print("choose card \(card.content) - \(card.id)")
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id }) {
            if !cards[chosenIndex].isFaceUp && !cards[chosenIndex].isMatched {
                if let potentialMatchIndex = indexOfFirstCardPicked {
                    print("2nd CARD")
                    
                    if cards[potentialMatchIndex].content == cards[chosenIndex].content {
                        print("MATCH!")
                        cards[potentialMatchIndex].isMatched = true
                        cards[chosenIndex].isMatched = true
                    }
                    else {
                        print("NO MATCH")
                        cards[potentialMatchIndex].isFaceUp = false
                    }
                    indexOfFirstCardPicked = nil
                }
                    
                else {
                    print("1st CARD")
                    indexOfFirstCardPicked = chosenIndex
                }
                cards[chosenIndex].isFaceUp = true
                }
            }
        }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    struct Card: Identifiable {
        
        let content: String
        var isFaceUp = false
        var hasBeenSeen = false
        var isMatched = false
        var id: String
        var debugDescription: String {
            """
            \(id): \(content) \(isFaceUp ? "up" : "down") Seen: \(hasBeenSeen) Matched: \(isMatched)
            """
        }
    }
}

