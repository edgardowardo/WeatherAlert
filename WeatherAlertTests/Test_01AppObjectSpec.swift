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
NB: If tests fail, please run as normal on simulator or device, before running test specs.

*/

class Test_01AppObjectSpec : QuickSpec {
    override func spec() {
        
        var testrealm : Realm!
        
        beforeEach {
            testrealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealmForTest"))
            AppObject.sharedInstance = AppObject.loadAppData(testrealm)
        }
        
        afterEach {
        }
        
        it ("checks default units is metric") {
            if let app = AppObject.sharedInstance {
                expect(app.units).to(equal(Units.Metric))
            }
        }
        
        it ("checks default distance is 2 km") {
            if let app = AppObject.sharedInstance {
                expect(app.distanceKm).to(equal(2.0))
            }
        }
        
        it ("saves the distance to 6 km") {
            if let app = AppObject.sharedInstance {
                try! testrealm.write{
                    app.distanceKm = 6.0
                }
            }
            
            if let app = testrealm.objects(AppObject).first {
                expect(app.distanceKm).to(equal(6.0))
            }
        }
        
        it("saves imperial units to the app settings") {
            
            if let app = AppObject.sharedInstance {
                app.units = .Imperial
            }
            
            if let app = testrealm.objects(AppObject).first {
                expect(app.units).to(equal(Units.Imperial))
            }
        }
        
        it("saves metric units to the app settings") {
            
            if let app = AppObject.sharedInstance {
                app.units = .Metric
            }
            
            if let app = testrealm.objects(AppObject).first {
                expect(app.units).to(equal(Units.Metric))
            }
        }
    }
}