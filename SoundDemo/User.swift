//
//  User.swift
//  SoundDemo
//
//  Created by ngocdm on 4/5/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

struct User {
    let userId: Int
    let name: String
    let bookmark: Bool
    
    init(userId: Int, name: String, bookmark: Bool) {
        self.userId = userId
        self.name = name
        self.bookmark = bookmark
    }
}
