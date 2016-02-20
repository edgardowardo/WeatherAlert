//
//  Alamofire.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Alamofire
import Ono

/*
    Note : I decided to use XML data since it provides more wind info such as wind name, direction code which simplifies plotting of cardinal direction. JSON data does not provide these descriptive data.
*/

extension Request {
    public static func XMLResponseSerializer() -> ResponseSerializer<ONOXMLDocument, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            do {
                let XML = try ONOXMLDocument(data: validData)
                return .Success(XML)
            } catch {
                return .Failure(error as NSError)
            }
        }
    }
    
    public func responseXMLDocument(completionHandler: Response<ONOXMLDocument, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
    }
}
