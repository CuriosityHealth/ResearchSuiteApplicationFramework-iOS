//
//  ViewController.swift
//  ResearchSuiteApplicationFramework
//
//  Created by jdkizer9 on 06/23/2017.
//  Copyright (c) 2017 jdkizer9. All rights reserved.
//

import UIKit
import ResearchSuiteApplicationFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let activityManager: RSActivityManager = RSApplicationDelegate.appDelegate.activityManager
        
        activityManager.setDelegate(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func yadlFullTapped(_ sender: Any) {
        
        let store = RSApplicationDelegate.appDelegate.store!
        store.dispatch(RSActionCreators.queueActivity(activityID: "yadlFull"))
        
    }
    
    @IBAction func yadlSpotTapped(_ sender: Any) {
        
        let store = RSApplicationDelegate.appDelegate.store!
        store.dispatch(RSActionCreators.queueActivity(activityID: "yadlSpot"))
        
    }
}

