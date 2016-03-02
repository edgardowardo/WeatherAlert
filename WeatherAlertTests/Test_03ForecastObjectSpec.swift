//
//  _03ForecastObjectSpec.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 01/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import XCTest
import RealmSwift
import Quick
import Nimble
@testable import WeatherAlert

class Test_03ForecastObjectSpec : QuickSpec {
    override func spec() {
        var realm : Realm!
        
        let location = NSBundle.mainBundle().pathForResource("testForecast01", ofType: "xml")
        let fileContent = try! NSString(contentsOfFile: location!, encoding: NSUTF8StringEncoding)
        
        beforeEach {
            realm = try! Realm()
        }
        
        afterEach {
        }
        
        it("saves forecast objects to the realm") {
            
            try! realm.write({ () -> Void in
                realm.delete(realm.objects(ForecastObject))
            })
            
            expect(realm.objects(ForecastObject).count).to(equal(0))
            
            self.measureBlock({ () -> Void in
                ForecastObject.saveXML(fileContent as String)
            })
            
            let f = realm.objects(ForecastObject)
            expect(f.count).to(equal(41))
            
            expect(f[0].cityid).to(equal(3333164))
            expect(f[0].hour).to(equal("21"))
            expect(f[0].speedvalue).to(equal(7.35))
            expect(f[0].speedname).to(equal("Moderate breeze"))
            expect(f[0].directioncode).to(equal("W"))
            expect(f[0].directionname).to(equal("West"))
            expect(f[0].directionvalue).to(equal(278.005))
            expect(f[0].temperatureUnit).to(equal("celsius"))
            expect(f[0].temperatureValue).to(equal(2.81))
            
            expect(f[1].cityid).to(equal(3333164))
            expect(f[1].hour).to(equal("00"))
            expect(f[1].speedvalue).to(equal(6.17))
            expect(f[1].speedname).to(equal("Moderate breeze"))
            expect(f[1].directioncode).to(equal("W"))
            expect(f[1].directionname).to(equal("West"))
            expect(f[1].directionvalue).to(equal(263.001))
            expect(f[1].temperatureUnit).to(equal("celsius"))
            expect(f[1].temperatureValue).to(equal(0.54))
   
            expect(f[2].cityid).to(equal(3333164))
            expect(f[2].hour).to(equal("03"))
            expect(f[2].speedvalue).to(equal(6.3))
            expect(f[2].speedname).to(equal("Moderate breeze"))
            expect(f[2].directioncode).to(equal("SW"))
            expect(f[2].directionname).to(equal("Southwest"))
            expect(f[2].directionvalue).to(equal(235.005))
            expect(f[2].temperatureUnit).to(equal("celsius"))
            expect(f[2].temperatureValue).to(equal(-0.18))
            
            expect(f[40].cityid).to(equal(3333164))
            expect(f[40].hour).to(equal("21"))
            expect(f[40].speedvalue).to(equal(1.96))
            expect(f[40].speedname).to(equal("Light breeze"))
            expect(f[40].directioncode).to(equal("W"))
            expect(f[40].directionname).to(equal("West"))
            expect(f[40].directionvalue).to(equal(272.505))
            expect(f[40].temperatureUnit).to(equal("celsius"))
            expect(f[40].temperatureValue).to(equal(-1.74))
        }
    }
}
