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

    //Variables for our UI Objects
    @IBOutlet weak var loadHRMDataButton: UIButton!
    @IBOutlet weak var startCheckingButton: UIButton!
    @IBOutlet weak var loadPMDataButton: UIButton!
    @IBOutlet weak var stopCheckingButton: UIButton!
    @IBOutlet weak var detailViewButton: UIButton!
    @IBOutlet weak var authorizeButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Object that handles the HealthKit Communication and Data
    var healthHandler: HealthHandler = HealthHandler()
    
    //var bpmHK:HKQuantitySample?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the activity indicator on start
        self.activityIndicator.hidden = true
        
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
        stopCheckingButton.layer.borderWidth = 1
        stopCheckingButton.layer.borderColor = UIColor.blackColor().CGColor
        detailViewButton.layer.borderWidth = 1
        detailViewButton.layer.borderColor = UIColor.blackColor().CGColor

        
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
            
        self.addMissingData({ (result:Bool, error:NSError!) -> Void in

            if(result == true){
                println("FINISHED STORING HRM DATA")
                
                
                
            }
        })

        
        
    }
    
    func activityIndicatorOff(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
    }
    
    func addMissingData(completion: (result: Bool, error: NSError!) -> Void){
        
        var date :NSDate? = NSDate().beginningOfDay()
        //println(today)
        let calendar = NSCalendar.currentCalendar()
        var comparisonDate: NSDate? = date
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        for (var index = 0; index <= 1440; index++ ) {
            
            var startDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: index, toDate: date!, options: nil)
            var endDate: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: (index + 1), toDate: date!, options: nil)
            

            healthHandler.checkSampleFromDates(sampleType, startDate: startDate!, endDate: endDate!, completion: { (result: Bool!, error: NSError!) -> Void in
                println("RESULT: \(result)")
                
               
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
                    let hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: NSDate())
                    println(hour)
                    
                }
                
                if(result == false){
                    println(false)
                    self.healthHandler.writeHeartRateSample(75.0, date: startDate!)
                }
                
                var lastDate:NSDate? = calendar.dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: date!, options: nil)

                
                
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
        
    }

    @IBAction func startChecking(sender: AnyObject) {
        
    }
    
    @IBAction func loadPMData(sender: AnyObject) {
        
    }
    
    @IBAction func stopChecking(sender: AnyObject) {
        
    }
    
    @IBAction func detailView(sender: AnyObject) {
        
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

