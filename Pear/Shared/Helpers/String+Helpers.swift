//
//  StringExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation
import UIKit

extension String {
  
  var length: Int {
    return count
  }
  
  subscript (index: Int) -> String {
    return self[index ..< index + 1]
  }
  
  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }
  
  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }
  
  subscript (ran: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, ran.lowerBound)),
                                        upper: min(length, max(0, ran.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }
  
  func splitIntoFirstLastName() -> (String, String) {
    var components = self.split(separator: " ")
    var firstName: String = ""
    var lastName: String = ""
    if components.count > 0 {
      firstName = String(components.removeFirst())
      lastName = String(components.joined(separator: " "))
    }
    return (firstName, lastName)
  }
  
  static func formatPhoneNumber(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
    guard !phoneNumber.isEmpty else { return "" }
    guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
    let range = NSString(string: phoneNumber).range(of: phoneNumber)
    var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: range, withTemplate: "")
    
    if number.count > 10 {
      let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
      number = String(number[number.startIndex..<tenthDigitIndex])
    }
    
    if shouldRemoveLastDigit {
      let end = number.index(number.startIndex, offsetBy: number.count-1)
      number = String(number[number.startIndex..<end])
    }
    
    if number.count < 7 {
      let end = number.index(number.startIndex, offsetBy: number.count)
      let range = number.startIndex..<end
      number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)
      
    } else {
      let end = number.index(number.startIndex, offsetBy: number.count)
      let range = number.startIndex..<end
      number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
    }
    
    return number
  }
  
  static func randomStringWithLength (len: Int) -> String {
    
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString: NSMutableString = NSMutableString(capacity: len)
    
    for _ in 0 ..< len {
      let length = UInt32 (letters.length)
      let rand = arc4random_uniform(length)
      randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString as String
  }
  
  public func levenshtein(_ other: String) -> Int {
    let sCount = self.count
    let oCount = other.count
    
    guard sCount != 0 else {
      return oCount
    }
    
    guard oCount != 0 else {
      return sCount
    }
    
    let line: [Int]  = Array(repeating: 0, count: oCount + 1)
    var mat: [[Int]] = Array(repeating: line, count: sCount + 1)
    
    for iIndex in 0...sCount {
      mat[iIndex][0] = iIndex
    }
    
    for jIndex in 0...oCount {
      mat[0][jIndex] = jIndex
    }
    
    for jIndex in 1...oCount {
      for iIndex in 1...sCount {
        if self[iIndex - 1] == other[jIndex - 1] {
          mat[iIndex][jIndex] = mat[iIndex - 1][jIndex - 1]       // no operation
        } else {
          let del = mat[iIndex - 1][jIndex] + 1         // deletion
          let ins = mat[iIndex][jIndex - 1] + 1         // insertion
          let sub = mat[iIndex - 1][jIndex - 1] + 1     // substitution
          mat[iIndex][jIndex] = min(min(del, ins), sub)
        }
      }
    }
    
    return mat[sCount][oCount]
  }

}

extension StringProtocol {
  var firstUppercased: String {
    return prefix(1).uppercased()  + dropFirst()
  }
  var firstCapitalized: String {
    return prefix(1).capitalized + dropFirst()
  }
}
