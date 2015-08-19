//
//  HeartBeatDataOperations.swift
//  HeartSync
//
//  Created by Clinton Medbery on 8/10/15.
//  Copyright (c) 2015 Programadores Sans Frontieres. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

enum HeartRateDataState {
    case New, HRMData, PMData, Ready, Compared, Uploaded
}

enum HeartRateDataOutcome {
    case NotDetermined, HeartRateMonitor, Pacemaker, Both
}

class HeartRateDataRecord {
    
    let startDate:NSDate
    let endDate:NSDate
    var state = HeartRateDataState.New
    var outcome = HeartRateDataOutcome.NotDetermined
    var heartRateMonitorReading: Double?
    var pacemakerReading: Double?
    
    
    init(startDate: NSDate, endDate: NSDate) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func printRecord(){
        println("SOURCE: \(state) HRM BPM: \(self.heartRateMonitorReading!) PM BPM: \(pacemakerReading) OUTCOME: \(outcome)")
        println("START DATE: \(startDate) END DATE: \(endDate)")
        
    }
}

class PendingComparisons {
    lazy var comparisonsInProgress = [NSIndexPath:NSOperation]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Comparison Queue"
        return queue
    }()
}

class DataComparer: NSOperation{
    
    let heartRateDataRecord: HeartRateDataRecord
    let healthHandler:HealthHandler = HealthHandler()
    
    init(heartRateDataRecord: HeartRateDataRecord){
        self.heartRateDataRecord = heartRateDataRecord
    }
    
    override func main(){
        
        if self.cancelled {
            return
        }
        
        //Operations
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        self.healthHandler.readHeartRateSampleFromDates(sampleType, startDate: heartRateDataRecord.startDate, endDate: heartRateDataRecord.endDate, completion: { (didRecieve, count, error) -> Void in
            
            println(count)
            
        })
        
        if self.cancelled{
            return
        }
        
        
        
    }
    
    
    
}

