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
    case New, Ready, Compared, Uploaded
}

enum HeartRateDataOutcome {
    case NotDetermined, HeartRateMonitor, Pacemaker, Both
}

class HeartRateDataRecord {
    
    let startDate:NSDate
    let endDate:NSDate
    var state = HeartRateDataState.New
    var outcome = HeartRateDataOutcome.NotDetermined
    var heartRateMonitorReading: Float?
    var pacemakerReading: Float?
    
    
    init(startDate: NSDate) {
        self.startDate = startDate
        
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
        
        self.healthHandler.readSampleFromDate(sampleType, startDate: heartRateDataRecord.startDate, completion: { (mostRecentHeartBeat, error) -> Void in
            
            println(mostRecentHeartBeat)
            
        })
        
        if self.cancelled{
            return
        }
        
        
        
    }
    
    
    
}

