//
//  NSDateExtensions.swift
//  HealthSaga
//
//  Created by Clinton Medbery on 7/1/15.
//  Copyright (c) 2015 Programadores Sans Frontieres. All rights reserved.
//

import Foundation

extension NSDate {
    
    func beginningOfDay() -> NSDate {
        let date: NSDate = NSDate()
        let cal: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let newDate: NSDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions())!
        return newDate
    }
    
    func endOfDay() -> NSDate {
        var components = NSDateComponents()
        components.day = 1
        var date = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self.beginningOfDay(), options: .allZeros)!
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
}

