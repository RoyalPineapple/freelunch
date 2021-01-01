//
//  Game.swift
//  FreeLunch
//
//  Created by Alex Odawa on 9/21/20.
//

import Foundation



struct Game {

    enum PlayState: Equatable {
        case stable
        case active([Card])
    }

    public private(set) var cells = Array(repeating: Cell(card: nil), count: 4)

    public private(set) var homes = [Card.Suit.heart : Home(suit: .heart),
                 .club : Home(suit: .club),
                 .diamond : Home(suit: .diamond),
                 .spade : Home(suit: .spade)]

    public private(set) var columns = Array(repeating: Column(), count: 8)

    public private(set)  var playState: PlayState = .stable


    public mutating func placeActiveCardInHome(_ suit: Card.Suit) {
        guard homes[suit] != nil else { fatalError("Cannot get homes for \(suit)") }
        guard case let PlayState.active(cards) = playState else {return }
        guard cards.count == 1 else {
            return
        }
        let result = homes[suit]!.add(cards.first!)
        switch result {
        case .success:
            playState = .stable
        case .failure:
            break
        }
    }

    public mutating func placeActiveCardAtCell(_ index: Int) {
        var cell = cells[index]
        guard case let PlayState.active(cards) = playState else {return }

        guard cards.count == 1, cell.card == nil else { return }
        cell.card = cards.first
        cells[index] = cell
        playState = .stable
    }

    public mutating func activateCardFromCell(_ index: Int) {
        var cell = cells[index]
        guard let card = cell.card, playState == .stable else {
            return
        }

        playState = .active([card])
        cell.card = nil
        cells[index] = cell
    }

    public mutating func placeActiveCardsAtColumn(_ index: Int) {
        var column = columns[index]
        guard case let PlayState.active(cards) = playState else {return }
        let result = column.place(cards, liberties: liberties)
        switch result {
        case .failure:
            return
        case .success:
            columns[index] = column
            playState = .stable
            return
        }
    }

    public mutating func activateCardsFrom(index: Int, in column:Int) {
        let result = columns[column].pickUp(from: index, liberties: liberties)
        switch result {
        case .failure:
            return
        case .success(let cards):
            playState = .active(cards)
            return
        }
    }

    var liberties: Int {
        return 52
//        var result = cells.reduce(into: 0, { (result, cell) in
//            if cell.card == nil {
//                result += 1
//            }
//        })
//        result = columns.reduce(into: 0, { (result, column) in
//            if column.cards.isEmpty {
//                result += 1
//            }
//        })
//        return result
    }


    static var newGame: Game {
        var game = Game()
        var deck = Card.newDeck


        for _ in 0..<6 {
            for columnIndex in 0..<game.columns.count {
                guard let card = deck.popLast() else { fatalError("could not deal card")}
                game.columns[columnIndex].cards.append(card)
            }
        }
        for i in 0..<4 {
            guard let card = deck.popLast() else { fatalError("could not deal card")}
            game.columns[i].cards.append(card)
        }

        assert(deck.isEmpty)

        return game
    }

}



extension Game {

    enum PlayError: Error {
        case badMove
        case tooFewLiberties
    }

    struct  Cell {
        var card: Card?
    }

    struct Home {
        let suit: Card.Suit
        var cards: [Card] = []

        var nextFace: Card.Face? {
            if let last = cards.last {
                guard let face = Card.Face(rawValue: last.face.rawValue + 1) else {
                    return nil
                }
                return face
            }
            return .ace
        }

        mutating func add(_ card:Card) -> Result<Void, PlayError> {
            guard let next = nextFace,
                card.face == next,
                card.suit == suit
            else {
                return .failure(.badMove)
            }

            cards.append(card)
            return.success(())
        }

    }

    struct Column {
        public fileprivate(set) var cards: [Card] = []

        mutating func place(_ cards:[Card], liberties: Int) -> Result<Void, PlayError> {

            if cards.count > liberties {
                return.failure(.badMove)
            }

            guard let first = cards.first else {
                // Cant place an empty stack of cards
                return .failure(.badMove)
            }
            guard let stack = self.cards.last else {
                // Column is empty, just place the cards there
                self.cards = cards
                return .success(())
            }

            if self.canStack(first, on: stack) {
                self.cards += cards
                return .success(())
            }

            return .failure(.badMove)
        }

        mutating func pickUp(from index: Int, liberties: Int) -> Result<[Card], PlayError> {

            guard cards.count - index <= liberties + 1 else {
                return .failure(.tooFewLiberties)
            }

            if !canPickUp(index) {
                return .failure(.badMove)
            }
            let pickedUp: [Card] = Array(cards[index..<cards.count])
            cards.removeSubrange(index..<cards.count)
            return .success(pickedUp)
        }


        private func canStack(_ top: Card, on bottom:Card) -> Bool {
            if top.suit.color == bottom.suit.color {
                // Suits must alternate
                return false
            }
            if top.face.rawValue != (bottom.face.rawValue - 1) {
                // Cards must decrement by one
                return false
            }
            return true
        }


        private func canPickUp(_ index: Int) -> Bool {
            guard index < cards.count else {
                return false
            }

            if  index == (cards.count - 1) {
                // Last card can always be picked up
                return true
            }

            let card = cards[index]
            let nextIndex = index + 1
            let next = cards[nextIndex]

            if !canStack(next, on: card ) {
                return false
            }
            return canPickUp(nextIndex)
        }
    }
}

struct Card: Equatable, CustomStringConvertible, Identifiable {
    
    let id = UUID()

    var description: String {
        var string = ""
        switch face {
        case .ace:
            string += "A"
        case .jack:
            string += "J"
        case .queen:
            string += "Q"
        case .king:
            string += "K"
        default:
            string += "\(face.rawValue)"
        }
        string += suit.rawValue
        return string
    }


    static var newDeck:[Card] {
        var deck: [Card] = []
        for suit in [Card.Suit.heart, .club, .diamond, .spade] {
            for faceValue in 1..<14 {
                guard let face = Card.Face(rawValue: faceValue)  else {
                    fatalError("Cannot create a card with value \(faceValue)")
                }
                deck.append(Card(suit: suit, face: face))
            }
        }
        return deck.shuffled()
    }




    enum Color {
        case red
        case black
        var opposite:Color {
            switch  self {
            case .red:
                return .black
            case .black:
                return .red
            }
        }
    }

    enum Suit: String {
        case heart = "♥️"
        case diamond = "♦️"
        case club = "♣️"
        case spade = "♠️"

        var color: Color {
            switch  self {
            case .heart, .diamond:
                return .red
            case .club, .spade:
                return .black
            }
        }
    }

    enum Face: Int {
        case ace = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
        case seven = 7
        case eight = 8
        case nine = 9
        case ten = 10
        case jack = 11
        case queen = 12
        case king = 13
    }

    let suit: Suit
    let face: Face


}



extension Card {
    var emoji: String {
        let cards: [String]
        switch face {
        case .ace:
            cards = ["🂡","🂱","🃁","🃑"]
        case .two:
            cards = ["🂢","🂲","🃂","🃒"]
        case .three:
            cards = ["🂣","🂳","🃃","🃓"]
        case .four:
            cards = ["🂤","🂴","🃄","🃔"]
        case .five:
            cards = ["🂥","🂵","🃅","🃕"]
        case .six:
            cards = ["🂦","🂶","🃆","🃖"]
        case .seven:
            cards = ["🂧","🂷","🃇","🃗"]
        case .eight:
            cards = ["🂨","🂸","🃈","🃘"]
        case .nine:
            cards = ["🂩","🂹","🃉","🃙"]
        case .ten:
            cards = ["🂪","🂺","🃊","🃚"]
        case .jack:
            cards = ["🂫","🂻","🃋","🃛"]
        case .queen:
            cards = ["🂭","🂽","🃍","🃝"]
        case .king:
            cards = ["🂮","🂾","🃎","🃞"]
        }

        switch suit {
        case .spade:
            return cards[0]
        case .heart:
            return cards[1]
        case .diamond:
            return cards[2]
        case .club:
            return cards[3]
        }
    }
}
