//
//  CurrentDetailViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

class CurrentDetailViewController: UIViewController {
    
    // MARK: - Properties -
    
    var current : CurrentObject?
    
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        
        let leftButton : UIBarButtonItem = UIBarButtonItem(image : UIImage(named: "icon-arrow-left"), style: .Done, target: self, action: Selector("back"))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(image : UIImage(named: "icon-star"), style: .Done, target: self, action: Selector("starred"))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - Helpers -
    
    func starred() {
        
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @objc private func methodOfReceivedNotification_didSaveCurrentObject(notification : NSNotification) {
        if let c = notification.object as? CurrentObject {
            self.current = c
        }
    }
}