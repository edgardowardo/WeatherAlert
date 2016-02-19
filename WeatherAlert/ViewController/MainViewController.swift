//
//  MainViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Weather Alert"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_willLoadCityData:", name: CityObject.Notification.Identifier.willLoadCityData, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didLoadCityData:", name: CityObject.Notification.Identifier.didLoadCityData, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addCity"))
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    // MARK: - Helpers -
    
    func addCity() {
        
        let citySearchViewController = UIStoryboard.citySearchViewController()
        let nav = UINavigationController(rootViewController: citySearchViewController!)
        presentViewController(nav, animated: true, completion: nil)
        
    }
    
    @objc private func methodOfReceivedNotification_willLoadCityData(notification : NSNotification) {
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    @objc private func methodOfReceivedNotification_didLoadCityData(notification : NSNotification) {
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
}

