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
    
    class func citySearchViewController() -> CitySearchViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CitySearchViewController") as? CitySearchViewController
    }
}