//
//  HeartBeatEntity.swift
//  
//
//  Created by Clinton Medbery on 7/30/15.
//
//

import Foundation
import CoreData

class HeartBeatEntity: NSManagedObject {

    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var bpm: NSNumber
    @NSManaged var source: String
    @NSManaged var heartRateId: NSNumber
    @NSManaged var isTestData: String

}
