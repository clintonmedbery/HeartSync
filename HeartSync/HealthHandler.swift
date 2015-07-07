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
    
}

