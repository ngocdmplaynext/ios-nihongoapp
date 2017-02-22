//
//  StringExtension.swift
//  SoundDemo
//
//  Created by ngocdm on 2/22/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

import UIKit

extension String {
    func index(of string: String, options: String.CompareOptions = .literal) -> Int? {
        if let range = range(of: string, options: options) {
            return distance(from: startIndex, to: range.lowerBound)
        }
        return nil
    }
    func indexes(of string: String, options: String.CompareOptions = .literal) -> [String.Index] {
        var result: [String.Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: String.CompareOptions = .literal) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
    
    func subStr(from offset: Int) -> String {
        let ind = index(startIndex, offsetBy: offset)
        return substring(from: ind)
    }
}
