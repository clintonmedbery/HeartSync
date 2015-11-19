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
        let components = NSDateComponents()
        components.day = 1
        var date = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self.beginningOfDay(), options: [])!
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
    
    func getCSVDescription() -> String {
        let calendar = NSCalendar.currentCalendar()

        let components = calendar.components([.Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: self)
        
        var minuteString:String = String(components.minute)
        
        if(components.minute < 10){
            minuteString = "0" + minuteString
        }
        
        var hourString: String = String(components.hour)
        
        if(components.hour < 10){
            hourString = "0" + hourString
        }
        
        var secondString: String = String(components.second)
        
        if(components.second < 10){
            secondString = "0" + secondString
        }
        
        let csvString = "\(components.month)/\(components.day)/\(components.year),\(hourString):\(minuteString):\(secondString)"
        return csvString
    }
    
    func basicDateComparison(otherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()

        let selfComponents = calendar.components([.Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: self)
        
        let otherComponents = calendar.components([.Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: otherDate)
        
        
        if(selfComponents == otherComponents){
            return true
        }
        
        return false
    }
    
    func getHour() -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.Hour, fromDate: self)
        print(components.hour)
        return components.hour
    }
    
    func getSeconds() -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.Second, fromDate: self)
        
        return components.second
    }
    
    func getMinute() -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.Minute, fromDate: self)
        print(components.minute)
        return components.minute
    }
    
    
}

