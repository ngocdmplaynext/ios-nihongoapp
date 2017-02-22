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
    var card: Card
    init(name: String, card: Card) {
        self.name = name
        self.card = card
    }
}
