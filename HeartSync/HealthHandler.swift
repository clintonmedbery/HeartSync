//
//  HealthHandler.swift
//  HealthSaga
//
//  Created by Clinton Medbery on 4/18/15.
//  Copyright (c) 2015 Programadores Sans Frontieres. All rights reserved.
//

import Foundation
import HealthKit

class HealthHandler {
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    init(){
        
        
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = NSSet(array:[
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            
            ])
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = NSSet(array:[
            
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)

            
            ])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "HealthSaga", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite as Set<NSObject>, readTypes: healthKitTypesToRead as Set<NSObject>) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func readRecentSample(sampleType: HKSampleType, completion: ((HKSample!, NSError!) -> Void)!) {
        
        //Build the Predicate
        let past = NSDate.distantPast() as! NSDate
        let now = NSDate()
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate: now, options: .None)
        
        let limit = 1
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                completion(nil, error)
                return;
            }
            
            let mostRecentSample = results.first as? HKQuantitySample
            
            if completion != nil {
                completion(mostRecentSample,nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func readDailySample(sampleType: HKSampleType, completion: ((HKSample!, NSError!) -> Void)!) {
        
        //Build the Predicate
        let endDate = NSDate()
        
        let startDate = endDate.beginningOfDay()
        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let limit = 0
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                completion(nil, error)
                return;
            }
            
            let mostRecentSample = results.first as? HKQuantitySample
            
            if completion != nil {
                completion(mostRecentSample,nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
        
        
    }
    
    func readStepSampleFromDates(sampleType: HKSampleType, startDate: NSDate, endDate: NSDate, completion: ((Int!, NSError!) -> Void)!) {
        println("READ")
        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let limit = 0
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                completion(nil, error)
                return;
            }
            var steps: Double = 0
            println(results.last)
            println(results.first)
            
            for result in results as! [HKQuantitySample]
            {
                //println(result)
                //println(result.quantity.doubleValueForUnit(HKUnit.countUnit()))
                
                steps += result.quantity.doubleValueForUnit(HKUnit.countUnit())
                //println(steps)
            }
            
            if completion != nil {
                completion(Int(steps),nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
        
        
    }
    
    func readSampleFromDate(sampleType: HKSampleType, startDate: NSDate, completion: ((HKSample!, NSError!) -> Void)!) {
        
        //Build the Predicate
        let endDate = NSDate()
        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let limit = 0
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                completion(nil, error)
                return;
            }
            
            let mostRecentSample = results.first as? HKQuantitySample
            
            if completion != nil {
                completion(mostRecentSample,nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
        
        
    }
    
    func getLastEntryFromToday(sampleType: HKSampleType, startDate: NSDate, completion: ((lastDate: NSDate!, error: NSError!) -> Void)!){
        
        //Build the Predicate
        let endDate = NSDate()
        println(startDate)
        println(endDate)

        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let limit = 0
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            
            if let queryError = error {
                //println(error)
                completion(lastDate: nil, error: error)
                return;
            }
            
            let mostRecentSample = results.first as? HKQuantitySample
            //println(results.first)
            if completion != nil {
                completion(lastDate: mostRecentSample?.startDate, error: nil)
            }
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
    }
    
    func writeHeartRateSample(bpm: Double, date: NSDate, completion: ((success: Bool!, error: NSError!) -> Void)!){
        let bpmType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        var heartRateUnit: HKUnit = HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
        let bpmQuantity = HKQuantity(unit: heartRateUnit, doubleValue: bpm)
        let bpmSample = HKQuantitySample(type: bpmType, quantity: bpmQuantity, startDate: date, endDate: date)
        
        self.healthKitStore.saveObject(bpmSample, withCompletion: { (success, error) -> Void in
            if( error != nil ) {
                println("Error saving BPM sample: \(error.localizedDescription)")
                completion(success: false, error: error)

            } else {
                println("BPM sample saved successfully! Start Date: \(date)  BPM: \(bpm)")
                completion(success: true, error: nil)
            }
        })
        
    }
    
    func checkSampleFromDates(sampleType: HKSampleType, startDate: NSDate, endDate: NSDate, completion: ((Bool!, NSError!) -> Void)!) {

        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let limit = 0
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            //println("RESULTS: \(results.count)")

            if let queryError = error {
                completion(false, error)
                //println("SENDING FALSE")
                return;
            }
            
            if(results.count > 0){
                //println("SENDING TRUE")

                completion(true,nil)
            }
            
            if (results.count <= 0) {
                //println("SENDING FALSE")

                completion(false,nil)
            }
            
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
        
        
    }

    func deleteSampleFromDates(sampleType: HKSampleType, startDate: NSDate, endDate: NSDate, completion: ((Bool!, NSError!) -> Void)!) {
        
        let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        let limit = 0
        
        //sortDescriptor will return the samples in descending order
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor]){ (sampleQuery, results, error) -> Void in
            //println("RESULTS: \(results.count)")
            
            if let queryError = error {
                
                completion(false, error)
                //println("SENDING FALSE")
                return;
            }
            
            if(results.count > 0){
                //println("SENDING TRUE")
                for(var i = 0; i <= results.count - 1; i++) {
                    var heartBeatResult: HKSample? = results[i] as? HKSample
                    self.healthKitStore.deleteObject(heartBeatResult!, withCompletion: { (success, error: NSError!) -> Void in
                        
                        println(heartBeatResult?.endDate)

                        if(success == true){
                            //println("OBJECT DELETED")
                            
                            
                        } else {
                            println("OBJECT DELETE ERROR")
                        }
                        
                        if(heartBeatResult?.startDate == startDate){
                            completion(true,nil)
                            
                        }
                    })
                }
                
            } else {
                
                completion(true,nil)
                
            }
            
            
            
        }
        
        self.healthKitStore.executeQuery(sampleQuery)
        
        
    }

    
    
}

