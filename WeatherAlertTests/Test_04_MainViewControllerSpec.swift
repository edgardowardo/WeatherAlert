//
//  Test_04_MainViewControllerSpec.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 02/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//
/*
import Foundation
import XCTest
import RealmSwift
import Quick
import Nimble
@testable import WeatherAlert

class Test_04MainViewContollerSpec : QuickSpec {
    override func spec() {
        var realm : Realm!

        let controller = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? MainViewController
        
        beforeEach {
            realm = try! Realm()
        }
        
        afterEach {
        }
        
        it("searches for leeds") {
            
            self.measureBlock({ () -> Void in
            
                if let currents = controller?.getCurrentObjects("Leeds") {
                    expect(currents.count).to(equal(2))
                    expect(currents[0].0).to(equal("FAVOURITES"))
                    expect(currents[1].0).to(equal("RECENTS"))
                    
                }
                
            })

           /*
            
            
            try! realm.write({ () -> Void in
                realm.delete(realm.objects(CurrentObject))
            })
            
            expect(realm.objects(CurrentObject).count).to(equal(0))
            
            self.measureBlock({ () -> Void in
                CurrentObject.saveXML(fileContent as String)
            })
            
            expect(realm.objects(CurrentObject).count).to(equal(1))
            
            let c = realm.objects(CurrentObject).first! as CurrentObject
            
            expect(c.cityid).to(equal(1684552))
            expect(c.name).to(equal("Tagaytay City"))
            expect(c.country).to(equal("PH"))
            expect(c.lon).to(equal(120.93))
            expect(c.lat).to(equal(14.11))
            expect(c.speedvalue).to(equal(2.6))
            expect(c.speedname).to(equal("Light breeze"))
            expect(c.directioncode).to(equal("NE"))
            expect(c.directionname).to(equal("NorthEast"))
            expect(c.directionvalue).to(equal(40))
            expect(c.isFavourite).to(equal(false))
            expect(c._units).to(equal(Units.Metric.rawValue)) */
        }
    }
}
*/
