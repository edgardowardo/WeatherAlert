//
//  Direction.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 17/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation


enum Direction : String {
    case N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
    
    static var directions : [Direction] {
        get {
            return [N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW]
        }
    }
    
    var name : String {
        get {
            switch self {
            case N :
                return "North"
            case NNE :
                return "North north east"
            case NE:
                return "North east"
            case ENE:
                return "East north east"
            case E:
                return "East"
            case ESE:
                return "East south east"
            case SE:
                return "South east"
            case SSE:
                return "South south east"
            case S:
                return "South"
            case SSW:
                return "South south west"
            case SW:
                return "South west"
            case WSW:
                return "West south west"
            case W:
                return "West"
            case WNW:
                return "West north west"
            case NW:
                return "North west"
            case NNW:
                return "North north west"
            }
        }
    }
    
    var inverse : Direction {
        get {
            switch self {
            case N :
                return S
            case NNE :
                return SSW
            case NE:
                return SW
            case ENE:
                return WSW
            case E:
                return W
            case ESE:
                return WNW
            case SE:
                return NW
            case SSE:
                return NNW
            case S:
                return N
            case SSW:
                return NNE
            case SW:
                return NE
            case WSW:
                return ENE
            case W:
                return E
            case WNW:
                return ESE
            case NW:
                return SE
            case NNW:
                return SSE
            }
        }
    }
    
    
}