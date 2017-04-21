//
//  Card.swift
//  SoundDemo
//
//  Created by ngocdm on 2/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

struct Card {
    var name: String
    var romaji: String
    var cardId: Int
    var deckId: Int
    var bestScore: Int
    init(name: String, cardId: Int, deckId: Int, bestScore: Int) {
        self.name = name
        self.romaji = MeCabUtil.shared().stringJapanese(toRomaji: name)
        self.cardId = cardId
        self.deckId = deckId
        self.bestScore = bestScore
    }
    
    init() {
        self.name = ""
        self.romaji = ""
        self.cardId = 0
        self.deckId = 0
        self.bestScore = 0
    }
}
