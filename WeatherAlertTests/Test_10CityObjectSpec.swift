//
//  WeatherAlertRealmTests.swift
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

class Test_10CityObjectSpec : QuickSpec {
    override func spec() {

        var realm : Realm!
        
        beforeEach {
            realm = try! Realm()
        }
        
        afterEach {
        }
        
        it("adds city objects to the realm") {
            
            try! realm.write({ () -> Void in
                realm.delete(realm.objects(CityObject))
            })
            
            expect(realm.objects(CityObject).count).to(equal(0))

            self.measureBlock({ () -> Void in
                CityObject.loadCityData()
            })
            
            expect(realm.objects(CityObject).count).toEventually( equal(209579), timeout: 60)
        }
    }
}

