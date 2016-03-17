//
//  Units.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 01/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import UIColor_FlatColors

enum PseudoSpeed {
    case Gentle, Moderate, Fresh, Strong
}

enum Units : String {
    case Metric , Imperial
    
    func toMs(mph : Double) -> Double {
        return mph / 2.237
    }
    
    func toMph(ms : Double) -> Double {
        return ms * 2.237
    }
    
    func toImperial(km : Double) -> Double {
        return km * 0.621371
    }
    
    var inverse : Units {
        get {
            switch self {
            case .Metric :
                return .Imperial
            case .Imperial :
                return .Metric
            }
        }
    }
    
    var short : String {
        get {
            switch self {
            case .Metric :
                return "km"
            case .Imperial :
                return "mi"
            }
        }
    }
    
    var lowercase : String {
        get {
            return self.rawValue.lowercaseString
        }
    }
    
    var speed : String {
        get {
            switch self {
            case .Metric :
                return "m/s"
            case .Imperial :
                return "mph"
            }
        }
    }
    
    var temperature : String {
        get {
            switch self {
            case .Metric :
                return "C"
            case .Imperial :
                return "F"
            }
        }
    }
    
    var maxSpeed : Double {
        switch self {
        case .Metric :
            return 17.0
        case .Imperial :
            return 38.0279
        }
    }
    
    func getLegendOfSpeed(pseudoSpeed : PseudoSpeed) -> String {
        switch self {
        case .Metric :
            switch pseudoSpeed {
            case .Gentle :
                return "0 - 6 \(speed)"
            case .Moderate :
                return "6 - 9 \(speed)"
            case .Fresh :
                return "9 - 15 \(speed)"
            case .Strong :
                return "15+ \(speed)"
            }
        case .Imperial :
            switch pseudoSpeed {
            case .Gentle :
                return "0 - 14 \(speed)"
            case .Moderate :
                return "14 - 21 \(speed)"
            case .Fresh :
                return "21 - 34 \(speed)"
            case .Strong :
                return "34+ \(speed)"
            }
        }
    }
    
    func getColorOfSpeed(speed : Double) -> UIColor {
        switch self {
        case .Metric :
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
        case .Imperial :
            switch speed {
            case 0.0 ... 13.4216 :
                return UIColor.flatBelizeHoleColor()
            case 13.4216 ... 20.1324 :
                return UIColor.flatGreenSeaColor()
            case 20.1324 ... 33.554 :
                return UIColor.flatOrangeColor()
            case 33.554 ... Double.infinity :
                return UIColor.flatPomegranateColor()
            default :
                return UIColor.flatCloudsColor()
            }
        }
    }
    
}