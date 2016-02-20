//
//  Router.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "http://api.openweathermap.org/data/2.5"
    static let appid = "86514c2ae159c18ed4c1908defe97b2d"
    static let mode = "xml"
    
    case Search(id : Int)
    
    // MARK: URLRequestConvertible protocol
    
    var URLRequest: NSMutableURLRequest {
        let result: (path: String, parameters: [String: AnyObject]) = {
            switch self {
            case .Search(let id) :
                return ("/weather?", ["APPID" : Router.appid, "mode" : Router.mode, "id" : id])
            }
        }()
        
        let URL = NSURL(string: Router.baseURLString)!
        let URLRequest = NSURLRequest(URL: URL.URLByAppendingPathComponent(result.path))
        let encoding = Alamofire.ParameterEncoding.URL
        
        return encoding.encode(URLRequest, parameters: result.parameters).0
    }
}