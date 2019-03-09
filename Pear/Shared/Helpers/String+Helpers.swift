//
//  StringExtensions.swift
//  Pear
//
//  Created by Avery Lamp on 2/11/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

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
  
}
