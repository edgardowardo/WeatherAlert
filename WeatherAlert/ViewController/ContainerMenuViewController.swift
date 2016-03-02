//
//  ContainerMenuViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import MBProgressHUD

protocol ContainerMenuViewDelegate {
    func showHud(text text : String)
    func hideHud()
}

extension ContainerMenuViewController : ContainerMenuViewDelegate {
    
    func showHud(text text : String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.dimBackground = true
        hud.labelText = text
    }
    
    func hideHud() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
}

class ContainerMenuViewController : SlideMenuController {

    override func isTagetViewController() -> Bool {
        if let vc = UIApplication.topViewController() {
            if vc is MainViewController {
                return true
            }
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_willLoadCityData:", name: CityObject.Notification.Identifier.willLoadCityData, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didLoadCityData:", name: CityObject.Notification.Identifier.didLoadCityData, object: nil)
    }
    
    @objc private func methodOfReceivedNotification_willLoadCityData(notification : NSNotification) {
        self.showHud(text: "Installing cities")
    }
    
    @objc private func methodOfReceivedNotification_didLoadCityData(notification : NSNotification) {
        self.hideHud()
    }
    
}
