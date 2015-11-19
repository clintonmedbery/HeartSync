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
        
        print("Started")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let heartBeatEntity = NSEntityDescription.entityForName("HeartBeatEntity", inManagedObjectContext: managedContext)
        
        let date :NSDate? = NSDate().beginningOfDay()
        let calendar = NSCalendar.currentCalendar()
        var comparisonDate: NSDate? = date
        for(var idNum = 1; idNum <= 1; idNum++){
            for (var index = 0; index <= 1439; index++ ) {
                
                let startDate: NSDate? = calendar.dateByAddingUnit(.Minute, value: index, toDate: date!, options: [])
                let endDate: NSDate? =  calendar.dateByAddingUnit(.Second, value: 59, toDate: startDate!, options: [])
                
                let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: startDate!)
                let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: startDate!)
                
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
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    
                    
                } else {
                    print("")
                    print("DATA ALREADY EXISTS")
                    print("ID: \(idNum)")
                    print("INDEX \(index)")
                    print("TIME \(startDate)")
                    print("HOUR: \(hour)")
                    print("MINUTE: \(minute)")
                }
                
            }
        }
        
        var error: NSError?
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        print("Finished")
        completion(result: true, error: nil)
    }
    
    func checkForStaticHeartRateData(heartRateID: Int, hour: Int, minute: Int ) -> Bool{
        
        let fetchRequest = NSFetchRequest(entityName: "HeartBeatEntity")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchedEntities = (try! managedContext.executeFetchRequest(fetchRequest)) as! [HeartBeatEntity]
        
        if(fetchedEntities.isEmpty){
            return false
        }
        
        for entity in fetchedEntities{
            
            let retrievedHour = NSCalendar.currentCalendar().component(.Hour, fromDate: entity.startDate)
            let retrievedMinute = NSCalendar.currentCalendar().component(.Minute, fromDate: entity.startDate)
            
            if(heartRateID == entity.heartRateId && minute == retrievedMinute && hour == retrievedHour) {
                
                return true
            }
            
        }
        
        return false
        
    }
    
    func getAllTestData() -> [HeartRateDataRecord] {
        
        let fetchRequest = NSFetchRequest(entityName: "HeartBeatEntity")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchedEntities = (try! managedContext.executeFetchRequest(fetchRequest)) as! [HeartBeatEntity]
        
        if(fetchedEntities.isEmpty){
            return []
        }
        
        var heartRateDataRecords = [HeartRateDataRecord]()
        let calendar = NSCalendar.currentCalendar()

        
        for entity in fetchedEntities{
            
            if(entity.isTestData == true) {
                let todayDate: NSDate = NSDate().beginningOfDay()
                let startComponents = calendar.components([.Minute, .Hour, .Second], fromDate: entity.startDate)
                var startDate = calendar.dateByAddingUnit(.Hour, value: startComponents.hour, toDate: todayDate, options: [])
                startDate = calendar.dateByAddingUnit(.Minute, value: startComponents.minute, toDate: startDate!, options: [])
                startDate = calendar.dateByAddingUnit(.Second, value: startComponents.second, toDate: startDate!, options: [])
                
                let endComponents = calendar.components([.Minute, .Hour, .Second], fromDate: entity.endDate)
                var endDate = calendar.dateByAddingUnit(.Hour, value: endComponents.hour, toDate: todayDate, options: [])
                endDate = calendar.dateByAddingUnit(.Minute, value: endComponents.minute, toDate: endDate!, options: [])
                endDate = calendar.dateByAddingUnit(.Second, value: endComponents.second, toDate: endDate!, options: [])
                
                
                
                
                let dataRecord:HeartRateDataRecord = HeartRateDataRecord(startDate: startDate!, endDate: endDate!)
                dataRecord.bpm = Double(entity.bpm)
                dataRecord.state = HeartRateDataState.PMData
                heartRateDataRecords.append(dataRecord)

                
            }
            
        }
        
       return heartRateDataRecords

    }
    
    
}