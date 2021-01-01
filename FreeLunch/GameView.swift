//
//  ContentView.swift
//  FreeLunch
//
//  Created by Alex Odawa on 9/21/20.
//

import SwiftUI

struct GameView: View {

    @State var game: Game = Game.newGame

    var body: some View {

       return VStack{
            HStack {
                CardView(card:game.cells[0].card) { _ in
                    self.didClickCell(0)
                }
                CardView(card:game.cells[1].card) { _ in
                    self.didClickCell(1)
                }
                CardView(card:game.cells[2].card) { _ in
                    self.didClickCell( 2)
                }
                CardView(card:game.cells[3].card) { _ in
                    self.didClickCell(3)
                }

                Spacer()
                Spacer()
                ZStack {
                    Text("♥️")
                        .font(.system(size: 100))
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.didClickHome(.heart)
                        })

                    CardView(card:game.homes[.heart]?.cards.last){ card in
                        self.didClickHome(.heart)
                    }
                }

                ZStack {
                    Text("♠️")
                        .font(.system(size: 100))
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.didClickHome(.spade)
                        })

                    CardView(card:game.homes[.spade]?.cards.last){ _ in
                        self.didClickHome(.spade)
                    }
                }

                ZStack {
                    Text("♦️")
                        .font(.system(size: 100))
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.didClickHome(.diamond)
                        })

                    CardView(card:game.homes[.diamond]?.cards.last){ _ in
                        self.didClickHome(.diamond)
                    }
                }

                ZStack {
                    Text("♣️")
                        .font(.system(size: 100))
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            self.didClickHome(.club)
                        })


                    CardView(card:game.homes[.club]?.cards.last){ _ in
                        self.didClickHome(.club)
                    }
                }
            }.padding()


            HStack {
                CardColumn(cards: game.columns[0].cards) { card in
                    self.didClick(card: card, columnIndex: 0)
                }
                CardColumn(cards: game.columns[1].cards){ card in
                    self.didClick(card: card, columnIndex: 1)
                }
                CardColumn(cards: game.columns[2].cards){ card in
                    self.didClick(card: card, columnIndex: 2)
                }
                CardColumn(cards: game.columns[3].cards){ card in
                    self.didClick(card: card, columnIndex: 3)
                }
                CardColumn(cards: game.columns[4].cards){ card in
                    self.didClick(card: card, columnIndex: 4)
                }
                CardColumn(cards: game.columns[5].cards){ card in
                    self.didClick(card: card, columnIndex: 5)
                }
                CardColumn(cards: game.columns[6].cards){ card in
                    self.didClick(card: card, columnIndex: 6)
                }
                CardColumn(cards: game.columns[7].cards){ card in
                    self.didClick(card: card, columnIndex: 7)
                }

            }.padding()

       }
       .padding()
       .background(Color.green)
       
    }

    func didClick(card: Card?, columnIndex: Int) {
        var mutableGame = game
        if mutableGame.playState != .stable {
            mutableGame.placeActiveCardsAtColumn(columnIndex)
        } else {
            let column = game.columns[columnIndex]
            guard let card = card else {fatalError("Card shouldnt be nil")}
            guard let cardIndex = column.cards.firstIndex(of: card) else {fatalError("Card needs to be in the column")}

            mutableGame.activateCardsFrom(index: cardIndex, in: columnIndex)
        }

        game = mutableGame

    }

    func didClickCell(_ index: Int) {
        var mutableGame = game
        if mutableGame.playState != .stable {
            mutableGame.placeActiveCardAtCell(index)
        } else {
            mutableGame.activateCardFromCell(index)
        }
        game = mutableGame
    }

    func didClickHome(_ suit: Card.Suit) {
        var mutableGame = game
        mutableGame.placeActiveCardInHome(suit)
        game = mutableGame
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: Game.newGame)
    }
}
