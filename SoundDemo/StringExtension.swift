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
    
    func ranges(of string: String, options: String.CompareOptions = .literal) -> [NSRange] {
        var result: [NSRange] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            let location = distance(from: startIndex, to: range.lowerBound)
            let length = distance(from: string.startIndex, to: string.endIndex)
            result.append(NSRange(location: location, length: length))
            start = range.upperBound
        }
        return result
    }
    
    func subStr(from offset: Int) -> String {
        let ind = index(startIndex, offsetBy: offset)
        return substring(from: ind)
    }
}
