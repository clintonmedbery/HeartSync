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

enum HeartRateDataState : Printable {
    case New, HRMData, PMData, ReadyForUpload, Compared, Uploaded
    var description : String {
        switch self {
            // Use Internationalization, as appropriate.
        case .New:
            return "New";
        case .HRMData:
            return "HRMData";
        case .PMData:
            return "PMData";
        case .ReadyForUpload:
            return "ReadyForUpload"
        case .Compared:
            return "Compared"
        case .Uploaded:
            return "Uploaded"
        }
    }
}

enum HeartRateDataOutcome :Printable {
    case NotDetermined, HeartRateMonitor, Pacemaker, Both
    var description: String {
        switch self {
        case .NotDetermined:
            return "NotDetermined"
        case .HeartRateMonitor:
            return "HeartRateMonitor"
        case .Pacemaker:
            return "Pacemaker"
        case .Both:
            return "Both"
        }
    }
}

class HeartRateDataRecord {
    
    let startDate:NSDate?
    let endDate:NSDate?
    var state = HeartRateDataState.New
    var outcome = HeartRateDataOutcome.NotDetermined
    var bpm: Double?
   
    
    
    init(startDate: NSDate, endDate: NSDate) {
        self.startDate = startDate
        self.endDate = endDate
        
    }
    
    func printRecord(){
        
        if(self.state == HeartRateDataState.PMData) {
            println("SOURCE: \(state) PM BPM: \(self.bpm!) OUTCOME: \(outcome)")
            println("START DATE: \(startDate!) END DATE: \(endDate)")

        } else if (self.state == HeartRateDataState.HRMData) {
            println("SOURCE: \(state) HRM BPM: \(self.bpm!) OUTCOME: \(outcome)")
            println("START DATE: \(startDate!) END DATE: \(endDate)")

        } else if (self.state == HeartRateDataState.Compared) {
            println("SOURCE: \(state) BPM: \(self.bpm!) OUTCOME: \(outcome)")
            println("START DATE: \(startDate!) END DATE: \(endDate)")

        }
        
    }
    
    func printCSVRecord() {
        switch self.outcome {
        case .Both:
            println("\(self.outcome.description), \(self.startDate!.getCSVDescription()), \(self.endDate!.getCSVDescription()), \(self.bpm!),,")
        case .HeartRateMonitor:
             println("\(self.outcome.description), \(self.startDate!.getCSVDescription()), \(self.endDate!.getCSVDescription()),,\(self.bpm!),")
        case .Pacemaker:
            println("\(self.outcome.description), \(self.startDate!.getCSVDescription()), \(self.endDate!.getCSVDescription()),,,\(self.bpm!)")
        case .NotDetermined:
            println("\(self.outcome.description), \(self.startDate!.getCSVDescription()), \(self.endDate!.getCSVDescription()),,,")
        }
        
        
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
        
        self.healthHandler.readHeartRateSampleFromDates(sampleType, startDate: heartRateDataRecord.startDate!, endDate: heartRateDataRecord.endDate!, completion: { (didRecieve, count, error) -> Void in
            
            println(count)
            
        })
        
        if self.cancelled{
            return
        }
        
        
        
    }
    
    
    
}

