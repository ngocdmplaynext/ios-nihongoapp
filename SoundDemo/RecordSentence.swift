//
//  RecordSentence.swift
//  SoundDemo
//
//  Created by ngocdm on 3/22/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

struct RecordSentence {
    var sentence: String
    var audioUrl: URL
    
    init(sentence: String, audioUrl: URL) {
        self.sentence = sentence
        self.audioUrl = audioUrl
    }
}
