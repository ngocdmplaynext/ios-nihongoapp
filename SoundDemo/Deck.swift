//
//  Deck.swift
//  SoundDemo
//
//  Created by ngocdm on 2/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

struct Deck {
    var name: String
    var deckId: Int
    var themeId: Int
    init(name: String, deckId: Int, themeId: Int) {
        self.name = name
        self.deckId = deckId
        self.themeId = themeId
    }
}
