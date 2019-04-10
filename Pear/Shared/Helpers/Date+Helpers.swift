//
//  Date+Helpers.swift
//  Pear
//
//  Created by Avery Lamp on 4/10/19.
//  Copyright © 2019 Setup and Matchmake Inc. All rights reserved.
//

import Foundation

extension Date {
  
  func distanceStringFromDate(date: Date) -> String {
    let currentDate = date
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(self)
    let latest = (earliest == now) ? self : now
    let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute,
                                                                          NSCalendar.Unit.hour,
                                                                          NSCalendar.Unit.day,
                                                                          NSCalendar.Unit.weekOfYear,
                                                                          NSCalendar.Unit.month,
                                                                          NSCalendar.Unit.year,
                                                                          NSCalendar.Unit.second],
                                                                         from: earliest,
                                                                         to: latest,
                                                                         options: NSCalendar.Options())
    
    if components.year! >= 2 {
      return "\(components.year!) years"
    } else if components.year! >= 1 {
      return "1 year"
    } else if components.month! >= 2 {
      return "\(components.month!) months"
    } else if components.month! >= 1 {
      return "1 month"
    } else if components.weekOfYear! >= 2 {
      return "\(components.weekOfYear!) weeks"
    } else if components.weekOfYear! >= 1 {
      return "1 week"
    } else if components.day! >= 2 {
      return "\(components.day!) days"
    } else if components.day! >= 1 {
      return "1 day"
    } else if components.hour! >= 2 {
      return "\(components.hour!) hours"
    } else if components.hour! >= 1 {
      return "1 hour"
    } else if components.minute! >= 2 {
      return "\(components.minute!) minutes"
    } else if components.minute! >= 1 {
      return "1 minute"
    } else if components.second! >= 3 {
      return "\(components.second!) seconds"
    } else {
      return "Just now"
    }
    
  }
  
  func timeAgoSinceDate(numericDates: Bool = false) -> String {
    let currentDate = Date()
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(self)
    let latest = (earliest == now) ? self : now
    let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute,
                                                                          NSCalendar.Unit.hour,
                                                                          NSCalendar.Unit.day,
                                                                          NSCalendar.Unit.weekOfYear,
                                                                          NSCalendar.Unit.month,
                                                                          NSCalendar.Unit.year,
                                                                          NSCalendar.Unit.second],
                                                                         from: earliest,
                                                                         to: latest,
                                                                         options: NSCalendar.Options())
    
    if components.year! >= 2 {
      return "\(components.year!) years ago"
    } else if components.year! >= 1 {
      if numericDates {
        return "1 year ago"
      } else {
        return "Last year"
      }
    } else if components.month! >= 2 {
      return "\(components.month!) months ago"
    } else if components.month! >= 1 {
      if numericDates {
        return "1 month ago"
      } else {
        return "Last month"
      }
    } else if components.weekOfYear! >= 2 {
      return "\(components.weekOfYear!) weeks ago"
    } else if components.weekOfYear! >= 1 {
      if numericDates {
        return "1 week ago"
      } else {
        return "Last week"
      }
    } else if components.day! >= 2 {
      return "\(components.day!) days ago"
    } else if components.day! >= 1 {
      if numericDates {
        return "1 day ago"
      } else {
        return "Yesterday"
      }
    } else if components.hour! >= 2 {
      return "\(components.hour!) hours ago"
    } else if components.hour! >= 1 {
      if numericDates {
        return "1 hour ago"
      } else {
        return "An hour ago"
      }
    } else if components.minute! >= 2 {
      return "\(components.minute!) minutes ago"
    } else if components.minute! >= 1 {
      if numericDates {
        return "1 minute ago"
      } else {
        return "A minute ago"
      }
    } else if components.second! >= 3 {
      return "\(components.second!) seconds ago"
    } else {
      return "Just now"
    }
    
  }
  
}
