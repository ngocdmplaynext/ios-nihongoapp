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
    var bestScore: Int
    init(name: String, bestScore: Int) {
        self.name = name
        self.bestScore = bestScore
    }
    
    init() {
        self.name = ""
        self.bestScore = 0
    }
}
