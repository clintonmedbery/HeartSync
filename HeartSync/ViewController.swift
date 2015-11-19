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
    @IBOutlet weak var dataSyncSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var dataSyncOn: Bool?
    
    //Object that handles the HealthKit Communication and Data
    var healthHandler: HealthHandler = HealthHandler()
    
    //Core Data Handler
    var heartBeatDataHandler: HeartBeatDataHandler = HeartBeatDataHandler()
    
    //var bpmHK:HKQuantitySample?
    
    var isHRMDataLoaded: Bool?
    var isHRMDataControl: Bool?
    
    var completeRecords = [HeartRateDataRecord]()
    let pendingComparisons = PendingComparisons()
    
    var operationQueue: NSOperationQueue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSyncOn = false
        dataSyncSwitch.setOn(true, animated: false)
        dataSyncSwitch.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)
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
        
        print("Start Animating")
        
        var startDate :NSDate? = NSDate().beginningOfDay()
        let calendar = NSCalendar.currentCalendar()

        var endDate: NSDate? = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: startDate!, options: [])
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)

        self.healthHandler.deleteSampleFromDates(sampleType!, startDate: startDate!, endDate: endDate!) { (success, error) -> Void in
            print(success)
            print(endDate)

            if let queryError = error {
                print("ERROR: \(error!)")
                
            }
            
            if(success == true) {
                
                
                
                self.addMissingData(75.0, completion: { (result:Bool, error:NSError!) -> Void in
                    
                    if(result == true){
                        print("FINISHED STORING HRM DATA")
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
            
            var startDate: NSDate? = calendar.dateByAddingUnit(.Minute, value: index, toDate: date!, options: [])
            var endDate: NSDate? =  calendar.dateByAddingUnit(.Second, value: 59, toDate: startDate!, options: [])
            

            healthHandler.checkSampleFromDates(sampleType!, startDate: startDate!, endDate: endDate!, completion: { (result: Bool!, error: NSError!) -> Void in
                //println("RESULT: \(result)")
               
                var lastDate:NSDate? = calendar.dateByAddingUnit(.Day, value: 1, toDate: date!, options: [])

                if let queryError = error {
                    print("ERROR: \(error!)")

                }

                if(result == true){
                    print("START DATE")
                    print(startDate!)
                    print("END DATE")
                    print(endDate!)
                    print("RESULT TRUE")
                    print(startDate!)
                    let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: startDate!)
                    print(hour)
                    
                    if(startDate! == lastDate){
                        print("FINISHED")
                        print(startDate!)
                        print(lastDate!)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicatorOff()
                            
                        }
                        completion(result: true, error: nil)
                    }
                    
                }
                
                if(result == false){
                    print(false)
                    
                    let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: startDate!)
                    let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: startDate!)
                    
                    var newHeartRate = heartRate
                    
                    if(hour <= 8 || hour >= 23){
                        newHeartRate = heartRate - 5.0
                        
                    }
                    
                    self.healthHandler.writeHeartRateSample(newHeartRate, startDate: startDate!, endDate: endDate!, completion: { (success, error) -> Void in
                        
                        if(startDate! == lastDate){
                            print("FINISHED")
                            print(startDate!)
                            print(lastDate!)
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
        let startComponents = calendar.components([.Minute, .Hour], fromDate: firstDate)
        let endComponents = calendar.components([.Minute, .Hour], fromDate: lastDate)
        
        
        //DOES NOT TAKE DAYS INTO ACCOUNT
        var numOfMinutes = endComponents.minute - startComponents.minute + ((endComponents.hour - startComponents.hour) * 60)
        print("MINUTES DIFFERENCE")
        print(numOfMinutes)

        for (var index = 0; index <= numOfMinutes; index++ ) {
            
            var entryStartDate: NSDate? = calendar.dateByAddingUnit(.Minute, value: index, toDate: firstDate, options: [])
            var entryEndDate: NSDate? =  calendar.dateByAddingUnit(.Second, value: 59, toDate: entryStartDate!, options: [])
            
            
            healthHandler.checkSampleFromDates(sampleType!, startDate: entryStartDate!, endDate: entryEndDate!, completion: { (result: Bool!, error: NSError!) -> Void in
                //println("RESULT: \(result)")
                
                
                if let queryError = error {
                    print("ERROR: \(error!)")
                    
                }
                
                if(result == true){
                    print("START DATE")
                    print(entryStartDate!)
                    print("END DATE")
                    print(entryEndDate!)
                    print("RESULT TRUE")
                
                
                    if(entryStartDate! == lastDate){
                        print("FINISHED")
                        print(entryStartDate!)
                        print(lastDate)
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
                            
                            print("Start Date: \(entryEndDate!)  Last Date: \(lastDate)")
                            
                            if(entryEndDate! == lastDate){
                                print("FINISHED")
                                print(entryStartDate!)
                                print(lastDate)
                                self.isHRMDataControl = false
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicatorOff()
                                    self.statusLabel.text = "Data Swapped (Random)"

                                    
                                }
                                completion(result: true, error: nil)
                            }
                        })

                        
                    } else {
                        
                        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: entryStartDate!)
                        
                        var newHeartRate = heartRate
                        
                        if(hour <= 8 || hour >= 23){
                            newHeartRate = heartRate - 5.0
                            
                        }
                        
                        self.healthHandler.writeHeartRateSample(newHeartRate, startDate: entryStartDate!, endDate: entryEndDate!, completion: { (success, error) -> Void in
                            
                            if(entryEndDate! == lastDate){
                                print("FINISHED")
                                print(entryStartDate!)
                                print(lastDate)
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
        
        print(dataSyncOn)
        operationQueue = NSOperationQueue()
        operationQueue?.name = "sync_Queue"
        completeRecords.removeAll(keepCapacity: false)
        
        
        
        var startDate :NSDate? = NSDate().beginningOfDay()
        var endDate = startDate?.endOfDay()
        //println(today)
        let calendar = NSCalendar.currentCalendar()
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        
        var heartRateMonitorRecords = [HeartRateDataRecord]()

        
        self.healthHandler.returnHeartRateSampleFromDates(sampleType!, startDate: startDate!, endDate: endDate!) { (success, hkDataRecords, error) -> Void in
            if(success == false){
                print("No Data")
                
            }
            if(success == true){
                for record in hkDataRecords {
                    //record.printCSVRecord()
                    heartRateMonitorRecords.append(record)
                }
                var pacemakerDataRecords = self.heartBeatDataHandler.getAllTestData() as [HeartRateDataRecord]
                
                
                
                if(self.dataSyncOn == true) {
                    
                    var pacemakerIndexCount: Int = pacemakerDataRecords.count - 1
                    var hrmIndexCount: Int = heartRateMonitorRecords.count - 1

                    
                    for (var i = 0; i < heartRateMonitorRecords.count; i++) {
                        
                        
                        for (var j = 0; j <= pacemakerIndexCount; j++) {
                            
                            print(j)
                            
                            if(heartRateMonitorRecords[i].startDate!.basicDateComparison(pacemakerDataRecords[j].startDate!) && heartRateMonitorRecords[i].endDate!.basicDateComparison(pacemakerDataRecords[j].endDate!)){
                                
                                
                                
                                
                                //Add sync here
                                if(heartRateMonitorRecords[i].bpm! == pacemakerDataRecords[j].bpm!) {
                                    
                                    
                                    var newDataRecord = HeartRateDataRecord(startDate: heartRateMonitorRecords[i].startDate!, endDate: heartRateMonitorRecords[i].endDate!)
                                    newDataRecord.bpm = heartRateMonitorRecords[i].bpm!
                                    newDataRecord.state = HeartRateDataState.ReadyForUpload
                                    newDataRecord.outcome = HeartRateDataOutcome.Both
                                    
                                    self.completeRecords.append(newDataRecord)
                                    
                                    heartRateMonitorRecords[i].state = HeartRateDataState.Compared
                                    pacemakerDataRecords[j].state = HeartRateDataState.Compared
                                    heartRateMonitorRecords.removeAtIndex(i)
                                    i = i - 1
                                    pacemakerDataRecords.removeAtIndex(j)
                                    j = j - 1
                                    
                                    pacemakerIndexCount = pacemakerDataRecords.count - 1
                                    hrmIndexCount = heartRateMonitorRecords.count - 1

                                    
                                    
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                    
                    for hrmRecord in heartRateMonitorRecords {
                        if(hrmRecord.state != HeartRateDataState.Compared) {
                            hrmRecord.outcome = HeartRateDataOutcome.HeartRateMonitor
                            hrmRecord.state = HeartRateDataState.ReadyForUpload
                            self.completeRecords.append(hrmRecord)
                        }
                    }
                    
                    
                    heartRateMonitorRecords.removeAll(keepCapacity: false)
                    
                    for pacemakerDataRecord in pacemakerDataRecords {
                        if (pacemakerDataRecord.state != HeartRateDataState.Compared) {
                            
                            pacemakerDataRecord.outcome = HeartRateDataOutcome.Pacemaker
                            pacemakerDataRecord.state = HeartRateDataState.ReadyForUpload
                            self.completeRecords.append(pacemakerDataRecord)
                        }
                    }
                    pacemakerDataRecords.removeAll(keepCapacity: false)
                    
                    
                    
                    
                    
                } else {
                    
                }
                
                for hrmRecord in heartRateMonitorRecords {
                    hrmRecord.outcome = HeartRateDataOutcome.HeartRateMonitor
                    hrmRecord.state = HeartRateDataState.ReadyForUpload
                    self.completeRecords.append(hrmRecord)
                }
                
                for pacemakerDataRecord in pacemakerDataRecords {
                    pacemakerDataRecord.outcome = HeartRateDataOutcome.Pacemaker
                    pacemakerDataRecord.state = HeartRateDataState.ReadyForUpload
                    self.completeRecords.append(pacemakerDataRecord)
                }
                
                print("CHECKING COMPLETE")

                
                
            }
        }
        
        
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
        startDate = calendar.dateByAddingUnit(NSCalendarUnit.Hour, value: hourOfDataSwap, toDate: startDate!, options: [])
        

        
        var endDate: NSDate? = calendar.dateByAddingUnit(NSCalendarUnit.Hour, value: 1, toDate: startDate!, options: [])
        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)

        
        self.healthHandler.deleteSampleFromDates(sampleType!, startDate: startDate!, endDate: endDate!) { (success, error) -> Void in
            print(success)
            print(endDate)
            
            if let queryError = error {
                print("ERROR: \(error!)")
                
            }
            
            if(success == true) {
                if(self.isHRMDataControl != nil) {
                    self.swapHRMData(75.0, isRandom: self.isHRMDataControl!, firstDate: startDate!, lastDate: endDate!, completion: { (result, error) -> Void in
                        
                        print("FINISHED SWAPPING HRM DATA")
                        
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
                print("HealthKit authorization received.")
                self.authorizeButton.enabled = false
                self.authorizeButton.alpha = 0.4
            }
            else
            {
                print("HealthKit authorization denied!")
                
                if error != nil {
                    print("\(error)")
                }
            }
        }
    
    }
    
    
    @IBAction func pushData(sender: AnyObject) {
        if (self.completeRecords.isEmpty) {
            print("COMPLETED RECORDS IS EMPTY")
            statusLabel.text = "No Data to Push"
            return
        } else {
            print("Data Type, Start Date, Start Time, End Date, End Time, Both, HRM, Pacemaker")
            for record in completeRecords {
                record.printCSVRecord()
            }
        }
        
        
        
    }

  
    func switchIsChanged(mySwitch: UISwitch) {
        if mySwitch.on {
            
            dataSyncOn = false
            
        } else {
            
            dataSyncOn = true
            
        }
        
        
        
    }
    
}

