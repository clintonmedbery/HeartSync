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

    @IBOutlet weak var loadHRMDataButton: UIButton!
    @IBOutlet weak var startCheckingButton: UIButton!
    @IBOutlet weak var loadPMDataButton: UIButton!
    @IBOutlet weak var stopCheckingButton: UIButton!
    @IBOutlet weak var detailViewButton: UIButton!
    @IBOutlet weak var authorizeButton: UIButton!
    
    var healthHandler: HealthHandler = HealthHandler()
    
    //var bpmHK:HKQuantitySample?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadHRMData(sender: AnyObject) {
//        var today :NSDate = NSDate().beginningOfDay()
//        println(today)
//        let calendar = NSCalendar.currentCalendar()
//        var date: NSDate? = calendar.dateByAddingUnit(.CalendarUnitMinute, value: 1, toDate: today, options: nil)
//        
//        for index in 1...5 {
//            println(date)
//            date = calendar.dateByAddingUnit(.CalendarUnitMinute, value: 1, toDate: date!, options: nil)
//
//        }
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        healthHandler.getLastEntryFromToday(sampleType, startDate: NSDate().beginningOfDay(), completion: { (lastDate: NSDate!, error: NSError!) -> Void in
            if(lastDate != nil) {
                println("Date")

                println(lastDate)
                
                
            }
            if let queryError = error {
                println("Error")
                println(error!)
                
                
            }

        })
        
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

