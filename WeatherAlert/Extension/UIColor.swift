//
//  UIColor.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 21/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIColor_FlatColors

extension UIColor {
    static func getColorOfSpeed(speed : Double) -> UIColor {
        switch speed {
        case 0.0 ... 6.0 :
            return UIColor.flatBelizeHoleColor()
        case 6.0 ... 9.0 :
            return UIColor.flatGreenSeaColor()
        case 9.0 ... 15 :
            return UIColor.flatOrangeColor()
        case 15 ... Double.infinity :
            return UIColor.flatPomegranateColor()
        default :
            return UIColor.flatCloudsColor()
        }
    }
}
