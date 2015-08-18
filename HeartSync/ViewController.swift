//
//  ViewController.swift
//  HeartSync
//
//  Created by Clinton Medbery on 7/6/15.
//  Copyright (c) 2015 Programadores Sans Frontieres. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let MINUTES_IN_DAY: Int = 1440

    //Variables for our UI Objects
    @IBOutlet weak var loadHRMDataButton: UIButton!
    @IBOutlet weak var startCheckingButton: UIButton!
    @IBOutlet weak var loadPMDataButton: UIButton!
    @IBOutlet weak var authorizeButton: UIButton!
    @IBOutlet weak var pushDataButton: UIButton!
    @IBOutlet weak var swapDataButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Object that handles the HealthKit Communication and Data
    var healthHandler: HealthHandler = HealthHandler()
    
    //Core Data Handler
    var heartBeatDataHandler: HeartBeatDataHandler = HeartBeatDataHandler()
    
    //var bpmHK:HKQuantitySample?
    
    var isHRMDataLoaded: Bool?
    var isHRMDataControl: Bool?
    
    var heartBeatDataRecords = [HeartRateDataRecord]()
    let pendingComparisons = PendingComparisons()
    
    var operationQueue: NSOperationQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the activity indicator on start
        self.activityIndicator.hidden = true
        
        //Say the data isn't loaded. Later I might add a checker that does this
        isHRMDataLoaded = false
        
        //UI Style setup
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "tree_bark.png")!)
        authorizeButton.layer.borderWidth = 1
        authorizeButton.layer.borderColor = UIColor.blackColor().CGColor
        loadHRMDataButton.layer.borderWidth = 1
        loadHRMDataButton.layer.borderColor = UIColor.blackColor().CGColor
        startCheckingButton.layer.borderWidth = 1
        startCheckingButton.layer.borderColor = UIColor.blackColor().CGColor
        loadPMDataButton.layer.borderWidth = 1
        loadPMDataButton.layer.borderColor = UIColor.blackColor().CGColor
        pushDataButton.layer.borderWidth = 1
        pushDataButton.layer.borderColor = UIColor.blackColor().CGColor
        swapDataButton.layer.borderWidth = 1
        swapDataButton.layer.borderColor = UIColor.blackColor().CGColor

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadHRMData(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidden = false
        }
        
        println("Start Animating")
        
        var startDate :NSDate? = NSDate().beginningOfDay()
        let calendar = NSCalendar.currentCalendar()

        var endDate: NSDate? = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitDay, value: 1, toDate: startDate!, options: nil)
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)

        self.healthHandler.deleteSampleFromDates(sampleType, startDate: startDate!, endDate: endDate!) { (success, error) -> Void in
            println(success)
            println(endDate)

            if let queryError = error {
                println("ERROR: \(error!)")
                
            }
            
            if(success == true) {
                self.addMissingData(75.0, completion: { (result:Bool, error:NSError!) -> Void in
                    
                    if(result == true){
                        println("FINISHED STORING HRM DATA")
                        self.isHRMDataLoaded = true
                        self.isHRMDataControl = true
                        self.statusLabel.text = "Data Loaded (Control)"
                        
                        
                    }
                })
            }

        }
        
    }
    
    func activityIndicatorOff(){
        dispatch_async(dispatch_get_main_queue()) {

            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }
    
    func addMissingData(heartRate: Double, completion: (result: Bool, error: NSError!) -> Void){
        
        var date :NSDate? = NSDate().beginningOfDay()
        //println(today)
        let calendar = NSCalendar.currentCalendar()
        var comparisonDate: NSDate? = date
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        for (var index = 0; index <= MINUTES_IN_DAY; index++ ) {
            
            var startDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: index, toDate: date!, options: nil)
            var endDate: NSDate? =  calendar.dateByAddingUnit(.CalendarUnitSecond, value: 59, toDate: startDate!, options: nil)
            

            healthHandler.checkSampleFromDates(sampleType, startDate: startDate!, endDate: endDate!, completion: { (result: Bool!, error: NSError!) -> Void in
                //println("RESULT: \(result)")
               
                var lastDate:NSDate? = calendar.dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: date!, options: nil)

                if let queryError = error {
                    println("ERROR: \(error!)")

                }

                if(result == true){
                    println("START DATE")
                    println(startDate!)
                    println("END DATE")
                    println(endDate!)
                    println("RESULT TRUE")
                    println(startDate!)
                    let hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: startDate!)
                    println(hour)
                    
                    if(startDate! == lastDate){
                        println("FINISHED")
                        println(startDate!)
                        println(lastDate!)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicatorOff()
                            
                        }
                        completion(result: true, error: nil)
                    }
                    
                }
                
                if(result == false){
                    println(false)
                    self.healthHandler.writeHeartRateSample(heartRate, startDate: startDate!, endDate: endDate!, completion: { (success, error) -> Void in
                        
                        if(startDate! == lastDate){
                            println("FINISHED")
                            println(startDate!)
                            println(lastDate!)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.activityIndicatorOff()
                                
                            }
                            completion(result: true, error: nil)
                        }
                    })
                }
                
                
                
                

            })
            
        }
        
    }
    
    func swapHRMData(heartRate: Double, isRandom: Bool, firstDate: NSDate, lastDate: NSDate, completion: (result: Bool, error: NSError!) -> Void){
        
        //println(today)
        let calendar = NSCalendar.currentCalendar()
        //var comparisonDate: NSDate? = date
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        let date = NSDate()
        let startComponents = calendar.components(.CalendarUnitMinute | .CalendarUnitHour, fromDate: firstDate)
        let endComponents = calendar.components(.CalendarUnitMinute | .CalendarUnitHour, fromDate: lastDate)
        
        
        //DOES NOT TAKE DAYS INTO ACCOUNT
        var numOfMinutes = endComponents.minute - startComponents.minute + ((endComponents.hour - startComponents.hour) * 60)
        println("MINUTES DIFFERENCE")
        println(numOfMinutes)

        for (var index = 0; index <= numOfMinutes; index++ ) {
            
            var entryStartDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: index, toDate: firstDate, options: nil)
            var entryEndDate: NSDate? =  calendar.dateByAddingUnit(.CalendarUnitSecond, value: 59, toDate: entryStartDate!, options: nil)
            
            
            healthHandler.checkSampleFromDates(sampleType, startDate: entryStartDate!, endDate: entryEndDate!, completion: { (result: Bool!, error: NSError!) -> Void in
                //println("RESULT: \(result)")
                
                
                if let queryError = error {
                    println("ERROR: \(error!)")
                    
                }
                
                if(result == true){
                    println("START DATE")
                    println(entryStartDate!)
                    println("END DATE")
                    println(entryEndDate!)
                    println("RESULT TRUE")
                
                
                    if(entryStartDate! == lastDate){
                        println("FINISHED")
                        println(entryStartDate!)
                        println(lastDate)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicatorOff()
                            
                        }
                        completion(result: true, error: nil)
                    }
                    
                }
                
                if(result == false){
                    //println(false)
                    
                    //Need to add randomness here
                    if(isRandom == true) {
                        
                        var newHeartRate: Int = Int(heartRate - 5) + Int(arc4random_uniform(10))
                        
                        self.healthHandler.writeHeartRateSample(Double(newHeartRate), startDate: entryStartDate!, endDate: entryEndDate!, completion: { (success, error) -> Void in
                            
                            println("Start Date: \(entryEndDate!)  Last Date: \(lastDate)")
                            
                            if(entryEndDate! == lastDate){
                                println("FINISHED")
                                println(entryStartDate!)
                                println(lastDate)
                                self.isHRMDataControl = false
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicatorOff()
                                    self.statusLabel.text = "Data Swapped (Random)"

                                    
                                }
                                completion(result: true, error: nil)
                            }
                        })

                        
                    } else {
                        
                        self.healthHandler.writeHeartRateSample(heartRate, startDate: entryStartDate!, endDate: entryEndDate!, completion: { (success, error) -> Void in
                            
                            if(entryEndDate! == lastDate){
                                println("FINISHED")
                                println(entryStartDate!)
                                println(lastDate)
                                self.isHRMDataControl = true

                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicatorOff()
                                    self.statusLabel.text = "Data Swapped (Control)"

                                    
                                }
                                completion(result: true, error: nil)
                            }
                        })

                    }
                    
                    
                }
                
            })
            
        }
        
    }


    @IBAction func startChecking(sender: AnyObject) {
        
        operationQueue = NSOperationQueue()
        operationQueue?.name = "sync_Queue"
        
        
        
        var date :NSDate? = NSDate().beginningOfDay()
        //println(today)
        let calendar = NSCalendar.currentCalendar()
        var comparisonDate: NSDate? = date
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        
        for (var index = 0; index <= MINUTES_IN_DAY; index++ ) {
            
            var startDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: index, toDate: date!, options: nil)
            var endDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitSecond, value: 59, toDate: startDate!, options: nil)
            let hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: startDate!)
            let minute = NSCalendar.currentCalendar().component(.CalendarUnitMinute, fromDate: startDate!)

            var heartRateDataRecord: HeartRateDataRecord = HeartRateDataRecord(startDate: startDate!, endDate: endDate!)
            
            let syncOperation = NSBlockOperation { () -> Void in
                
            
                let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            
                self.healthHandler.readHeartRateSampleFromDates(sampleType, startDate: startDate!, endDate: endDate!, completion: { (didRecieve, count, error) -> Void in
                
                    println(count)
                    
                    
                })
                
            }
            syncOperation.completionBlock = {
                println("COMPLETE")
            }
            
            
            syncOperation.queuePriority = NSOperationQueuePriority.High
            operationQueue?.addOperation(syncOperation)
            
            
        }

        
        
        
        
        
//        var date :NSDate? = NSDate().beginningOfDay()
//        //println(today)
//        let calendar = NSCalendar.currentCalendar()
//        var comparisonDate: NSDate? = date
//        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
//        let operationQueue = NSOperationQueue.mainQueue()
//        
//        
//        for (var index = 0; index <= MINUTES_IN_DAY; index++ ) {
//            var startDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: index, toDate: date!, options: nil)
//            var endDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: (index + 1), toDate: date!, options: nil)
//            
//            let heartRateDataRecord: HeartRateDataRecord = HeartRateDataRecord(startDate: startDate!, endDate: endDate!)
//            self.heartBeatDataRecords.append(heartRateDataRecord)
//            println(startDate)
//            println(endDate)
//            
//            let syncOperation: DataComparer = DataComparer(heartRateDataRecord: heartRateDataRecord)
//            
//            syncOperation.completionBlock = {
//                println("COMPLETE")
//            }
//            
//            operationQueue.addOperation(syncOperation)
//            
//
//        }
        
        
        
        
    }
    
    @IBAction func loadPMData(sender: AnyObject) {
        
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidden = false
            
        }
        heartBeatDataHandler.loadPacemakerData({ (result:Bool, error:NSError!) -> Void in
            
            
            self.activityIndicatorOff()
            
        
        })
    }
    
    
    @IBAction func pushData(sender: AnyObject) {
        
    }
    
    @IBAction func swapHRMData(sender: AnyObject) {
        
        if(isHRMDataLoaded == false) {
            statusLabel.text = "Load Data First"
            return
        }
        
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidden = false
        }
        let calendar = NSCalendar.currentCalendar()

        var hourOfDataSwap: Int = 17
        
        var startDate :NSDate? = NSDate().beginningOfDay()
        startDate = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: hourOfDataSwap, toDate: startDate!, options: nil)
        

        
        var endDate: NSDate? = calendar.dateByAddingUnit(NSCalendarUnit.CalendarUnitHour, value: 1, toDate: startDate!, options: nil)
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)

        
        self.healthHandler.deleteSampleFromDates(sampleType, startDate: startDate!, endDate: endDate!) { (success, error) -> Void in
            println(success)
            println(endDate)
            
            if let queryError = error {
                println("ERROR: \(error!)")
                
            }
            
            if(success == true) {
                if(self.isHRMDataControl != nil) {
                    self.swapHRMData(75.0, isRandom: self.isHRMDataControl!, firstDate: startDate!, lastDate: endDate!, completion: { (result, error) -> Void in
                        
                        println("FINISHED SWAPPING HRM DATA")
                        
                    })
                } else {
                    self.statusLabel.text = "Load Data First"
                    return
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func authorizeHealthKit(sender: AnyObject) {
        healthHandler.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
                self.authorizeButton.enabled = false
                self.authorizeButton.alpha = 0.4
            }
            else
            {
                println("HealthKit authorization denied!")
                
                if error != nil {
                    println("\(error)")
                }
            }
        }
    
    }
    
}

