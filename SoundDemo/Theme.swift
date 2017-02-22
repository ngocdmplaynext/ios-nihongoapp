//
//  Theme.swift
//  SoundDemo
//
//  Created by ngocdm on 2/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

struct Theme {
    var name: String
    var decks: [Deck]
    init(name: String, decks: [Deck]) {
        self.name = name
        self.decks = decks
    }
}
