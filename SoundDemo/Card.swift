//
//  Card.swift
//  SoundDemo
//
//  Created by ngocdm on 2/21/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

class Card {
    var name: String
    var romaji: String
    var bestScore: Int
    init(name: String, romaji: String, bestScore: Int) {
        self.name = name
        self.romaji = romaji
        self.bestScore = bestScore
    }
    
    init() {
        self.name = ""
        self.romaji = ""
        self.bestScore = 0
    }
}
