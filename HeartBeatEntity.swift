//
//  HeartBeatEntity.swift
//  HeartSync
//
//  Created by Clinton Medbery on 7/31/15.
//  Copyright (c) 2015 Programadores Sans Frontieres. All rights reserved.
//

import Foundation
import CoreData

@objc(HeartBeatEntity)
class HeartBeatEntity: NSManagedObject {

    @NSManaged var bpm: NSNumber
    @NSManaged var endDate: NSDate
    @NSManaged var heartRateId: NSNumber
    @NSManaged var isTestData: NSNumber
    @NSManaged var source: String
    @NSManaged var startDate: NSDate

}
