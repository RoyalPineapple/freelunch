//
//  CellView.swift
//  FreeLunch
//
//  Created by Alex Odawa on 9/22/20.
//

import SwiftUI

struct CellView: View {
    var cards: [Card]


    var body: some View {
        
        Group {
            if cards.isEmpty {
                
            } else {

                CardView(card: cards.last!)
            }
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(cards:[])
    }
}
