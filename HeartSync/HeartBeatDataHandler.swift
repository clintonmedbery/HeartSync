//
//  HeartBeatDataHandler.swift
//  HeartSync
//
//  Created by Clinton Medbery on 7/30/15.
//  Copyright (c) 2015 Programadores Sans Frontieres. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class HeartBeatDataHandler {
    
    var fetchedResultsController:NSFetchedResultsController!
    
    init(){
        
    }
    
    func loadPacemakerData(completion: (result: Bool, error: NSError!) -> Void) {
        
        println("Started")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let heartBeatEntity = NSEntityDescription.entityForName("HeartBeatEntity", inManagedObjectContext: managedContext)
        
        var date :NSDate? = NSDate().beginningOfDay()
        let calendar = NSCalendar.currentCalendar()
        var comparisonDate: NSDate? = date
        for(var idNum = 1; idNum <= 1; idNum++){
            for (var index = 0; index <= 1439; index++ ) {
                
                var startDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: index, toDate: date!, options: nil)
                var endDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: (index + 1), toDate: date!, options: nil)
                
                let hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: startDate!)
                let minute = NSCalendar.currentCalendar().component(.CalendarUnitMinute, fromDate: startDate!)
                
                if(self.checkForStaticHeartRateData(idNum, hour: hour, minute: minute) == false){
//                    println()
//                    println("WRITING...")
//                    println("ID: \(idNum)")
//                    println("INDEX \(index)")
//                    println("TIME \(startDate)")
//                    println("HOUR: \(hour)")
//                    println("MINUTE: \(minute)")
                    let storeHeartBeat = NSManagedObject(entity: heartBeatEntity!, insertIntoManagedObjectContext: managedContext)
                
                    storeHeartBeat.setValue(idNum, forKey: "heartRateId")
                    if(hour <= 8 || hour >= 23){
                        storeHeartBeat.setValue(70.0, forKey: "bpm")
//                        println("BPM: 70")
                    
                    }
                    if(hour > 8 && hour < 23){
                        storeHeartBeat.setValue(75.0, forKey: "bpm")
//                        println("BPM: 75")

                    }
                    storeHeartBeat.setValue(startDate, forKey: "startDate")
                    storeHeartBeat.setValue(endDate, forKey: "endDate")
                    storeHeartBeat.setValue(true, forKey: "isTestData")
                    storeHeartBeat.setValue("Pacemaker", forKey: "source")
                    
                    
                    
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    
                    
                } else {
                    println()
                    println("DATA ALREADY EXISTS")
                    println("ID: \(idNum)")
                    println("INDEX \(index)")
                    println("TIME \(startDate)")
                    println("HOUR: \(hour)")
                    println("MINUTE: \(minute)")
                }
                
            }
        }
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        println("Finished")
        completion(result: true, error: nil)
    }
    
    func checkForStaticHeartRateData(heartRateID: Int, hour: Int, minute: Int ) -> Bool{
        
        let fetchRequest = NSFetchRequest(entityName: "HeartBeatEntity")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchedEntities = managedContext.executeFetchRequest(fetchRequest, error: nil) as! [HeartBeatEntity]
        
        if(fetchedEntities.isEmpty){
            return false
        }
        
        for entity in fetchedEntities{
            
            let retrievedHour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: entity.startDate)
            let retrievedMinute = NSCalendar.currentCalendar().component(.CalendarUnitMinute, fromDate: entity.startDate)
            
            if(heartRateID == entity.heartRateId && minute == retrievedMinute && hour == retrievedHour) {
                
                return true
            }
            
        }
        
        return false
        
    }
    
    
}