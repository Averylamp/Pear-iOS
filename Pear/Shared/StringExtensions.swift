//
//  StringExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 sam. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func splitIntoFirstLastName() -> (String, String){
        var components = self.split(separator: " ")
        var firstName: String = ""
        var lastName: String = ""
        if components.count > 0{
            firstName = String(components.removeFirst())
            lastName = String(components.joined(separator: " "))
        }
        return (firstName, lastName)
    }
    
}
