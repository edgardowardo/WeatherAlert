//
//  AppObjectSpec.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 01/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import XCTest
import RealmSwift
import Quick
import Nimble
@testable import WeatherAlert

/*
NB: These test specs are named with prefix numbers in order to force the order of execution. CityObjectSpec to be done in the end because it's the longest test.
*/

class _01AppObjectSpec : QuickSpec {
    override func spec() {
        
        var realm : Realm!
        
        beforeEach {
            realm = try! Realm()
        }
        
        afterEach {
        }
        
        it("saves imperial units to the app settings") {
            
            if let app = AppObject.sharedInstance {
                app.units = .Imperial
            }
            
            if let app = realm.objects(AppObject).first {
                expect(app.units).to(equal(Units.Imperial))
            }
        }
        
        it("saves metric units to the app settings") {
            
            if let app = AppObject.sharedInstance {
                app.units = .Metric
            }
            
            if let app = realm.objects(AppObject).first {
                expect(app.units).to(equal(Units.Metric))
            }
        }
    }
}