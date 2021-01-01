//
//  CardView.swift
//  FreeLunch
//
//  Created by Alex Odawa on 9/22/20.
//

import SwiftUI

typealias clickHander = (Card?) -> Void

struct CardView: View, Identifiable {
    var id = NSUUID()

    typealias ClickHandler = (Card?) -> Void

    let card: Card?

    var clickHandler: ClickHandler

    var color: Color {
        guard let card = card else { return Color.clear}
        switch card.suit.color {
        case .red:
            return .red
        case .black:
            return .black
        }
    }

    var body: some View {
        let strokeColor = card == nil ? Color.white : .clear
        let backgroundColor = card == nil ? Color(white: 0.0, opacity: 0.2): .white
         return ZStack {
            Text(card?.emoji ?? "")
                .font(.system(size: 315))
                .foregroundColor(color)
                .scaledToFill()
                .offset(CGSize(width: -20.0, height: -35.0))

            RoundedRectangle(cornerRadius: 5.0)
                .stroke(strokeColor, lineWidth: 8)
         }
         .background(backgroundColor)
         .frame(width: 180.0, height: 240.0)
         .cornerRadius(5.0)
         .shadow(radius: 10, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 0.5)
         .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
             clickHandler(card)
         })
      }
}

struct CardView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CardView(card: nil) { (card) in
                print("I got clicked")
            }

            CardView(card: Card(suit: .heart, face: .king)) { (card) in
                //
            }

            CardColumn(cards: [Card(suit: .heart, face: .king), Card(suit: .club, face: .queen), Card(suit: .diamond, face: .jack), Card(suit: .spade, face: .ten)]) { _ in }

            CardColumn(cards: []) {_ in }

        }
    }
}

struct CardColumn: View {

    internal init(cards: [Card], clickHandler: @escaping CardView.ClickHandler, isActive: Bool = false) {
        self.cards = cards
        self.isActive = isActive
        self.clickHandler = clickHandler
    }

    let cards: [Card]
    var isActive: Bool

    var clickHandler: CardView.ClickHandler



    var body: some View {
        let maxCards = 18
        let stackheight:CGFloat
        if isActive{
            stackheight = 240 + (35.0 * CGFloat(cards.count))
        } else {
            stackheight  = 240.0 + (35.0 * CGFloat(maxCards))
        }
        
        return ZStack {
            GeometryReader { geometry in
            CardView(card:cards.first, clickHandler: clickHandler)
            ForEach(cards) { card in
                Group {
                    let index = cards.firstIndex(of: card)!
//                    if index >= cards.count {
//                        // some reason the indicies are getting out of sync
//                        EmptyView()
//                    } else {
                    CardView(card:cards[index],  clickHandler: clickHandler)
                        .offset(x: 0, y: 35.0 * CGFloat(index))
//                    }
                }
            }

            }.frame(width: 180.0, height: stackheight)

        }

    }
}

