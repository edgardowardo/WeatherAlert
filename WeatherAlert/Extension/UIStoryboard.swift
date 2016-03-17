//
//  UIStoryboard.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func currentDetailViewController() -> CurrentDetailViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CurrentDetailViewController") as? CurrentDetailViewController
    }
    
    class func donationViewController() -> DonationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DonationViewController") as? DonationViewController
    }
    
    class func mapViewController() -> MapViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MapViewController") as? MapViewController
    }
    
    class func alarmSettingViewController() -> AlarmSettingViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("AlarmSettingViewController") as? AlarmSettingViewController
    }
    
}