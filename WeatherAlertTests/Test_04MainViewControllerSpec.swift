//
//  Test_04_MainViewControllerSpec.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 02/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import XCTest
import RealmSwift
import Quick
import Nimble
@testable import WeatherAlert

class Test_04MainViewContollerSpec : QuickSpec {
    override func spec() {

        var testController : MainViewController!
        var testRealm : Realm!
        var defaultController : MainViewController!
        var defaultRealm : Realm!
        
        beforeEach {
            defaultRealm = try! Realm()
            defaultController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? MainViewController
            defaultController.realm = defaultRealm
            testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "InMemoryRealmForTest"))
            testController = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? MainViewController
            testController.realm = testRealm

            let currents = testRealm.objects(CurrentObject)
            let forecasts = testRealm.objects(ForecastObject)
            try! testRealm.write {
                testRealm.delete(currents)
                testRealm.delete(forecasts)
            }
        }
        
        afterEach {
        }
        
        it("filters for leeds") {
            if let c = defaultController {
                let currents = c.getCurrentObjects("Leeds")
                expect(currents.count).to(equal(2))
                expect(currents[0].0).to(equal("FAVOURITES - 0"))
                expect(currents[1].0).to(equal("RECENTS - 0"))
            }
        }
        
        it("searches for leeds") {
            if let c = defaultController {
                
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "Leeds"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 5"))
                
                let entry = fi[0].1[0]
                expect(entry.cityid).to(equal(3333164))
                expect(entry.name).to(equal("City and Borough of Leeds"))
                expect(entry.country).to(equal("GB"))
                expect(entry.isFavourite).to(equal(false))
            }
        }
        
        it("searches for manchester") {
            if let c = defaultController {
                
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "Manchester"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 20"))
                
                let entry = fi[0].1[1]
                expect(entry.cityid).to(equal(3333169))
                expect(entry.name).to(equal("City and Borough of Manchester"))
                expect(entry.country).to(equal("GB"))
                expect(entry.isFavourite).to(equal(false))
            }
        }
        
        it("searches for tagaytay") {
            if let c = defaultController {
                
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "Tagaytay"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 1"))
                
                let entry = fi[0].1[0]
                expect(entry.cityid).to(equal(1684552))
                expect(entry.name).to(equal("Tagaytay City"))
                expect(entry.country).to(equal("PH"))
                expect(entry.isFavourite).to(equal(false))
            }
        }
        
        it("searches for greater london") {
            if let c = defaultController {
                
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "London"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 26"))
                
                let entry = fi[0].1[1]
                expect(entry.cityid).to(equal(2648110))
                expect(entry.name).to(equal("Greater London"))
                expect(entry.country).to(equal("GB"))
                expect(entry.isFavourite).to(equal(false))
            }
        }

        it("searches for leeds and query open weather api server") {
            if let c = defaultController {
                
                expect(testRealm.objects(CurrentObject).count).to( equal(0))
                expect(testRealm.objects(ForecastObject).count).to( equal(0))
                
                // NB. Use default realm but use an injected test realm for current and forecast objects to write to
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "Leeds"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 5"))
                
                let entry = fi[0].1[0]
                expect(entry.cityid).to(equal(3333164))
                expect(entry.name).to(equal("City and Borough of Leeds"))
                expect(entry.country).to(equal("GB"))
                expect(entry.isFavourite).to(equal(false))
                
                let tc = testController
                let selectedObject = c.filteredObjects[0].1[0]
                tc.showCurrentObject(selectedObject)
                
                expect(testRealm.objects(CurrentObject).count).toEventually( equal(1), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.cityid).toEventually( equal(3333164), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.name).toEventually( equal("City and Borough of Leeds"), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.country).toEventually( equal("GB"), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.isFavourite).toEventually( equal(false), timeout: 60)
                
                // we can't determine exactly what's the number of forecast objects
                expect(testRealm.objects(ForecastObject).count).toEventually( beGreaterThan(0), timeout: 120)
                expect(testRealm.objects(ForecastObject).first?.cityid).toEventually( equal(3333164), timeout: 120)
            }
        }
        
        it("searches for manchester and query open weather api server") {
            if let c = defaultController {
                
                expect(testRealm.objects(CurrentObject).count).to( equal(0))
                expect(testRealm.objects(ForecastObject).count).to( equal(0))
                
                // NB. Use default realm but use an injected test realm for current and forecast objects to write to
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "Manchester"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 20"))
                
                let entry = fi[0].1[1]
                expect(entry.cityid).to(equal(3333169))
                expect(entry.name).to(equal("City and Borough of Manchester"))
                expect(entry.country).to(equal("GB"))
                expect(entry.isFavourite).to(equal(false))
                
                let tc = testController
                let selectedObject = c.filteredObjects[0].1[0]
                tc.showCurrentObject(selectedObject)
                
                expect(testRealm.objects(CurrentObject).count).toEventually( equal(1), timeout: 120)
//                expect(testRealm.objects(CurrentObject).first?.cityid).toEventually( equal(3333169), timeout: 120)
//                expect(testRealm.objects(CurrentObject).first?.name).toEventually( equal("City and Borough of Manchester"), timeout: 60)
//                expect(testRealm.objects(CurrentObject).first?.country).toEventually( equal("GB"), timeout: 60)
//                expect(testRealm.objects(CurrentObject).first?.isFavourite).toEventually( equal(false), timeout: 60)
                
//                // we can't determine exactly what's the number of forecast objects
                expect(testRealm.objects(ForecastObject).count).toEventually( beGreaterThan(0), timeout: 120)
//                expect(testRealm.objects(ForecastObject).first?.cityid).toEventually( equal(3333169), timeout: 120)
            }
        }
        
        it("searches for tagaytay and query open weather api server") {
            if let c = defaultController {
                
                expect(testRealm.objects(CurrentObject).count).to( equal(0))
                expect(testRealm.objects(ForecastObject).count).to( equal(0))
                
                // NB. Use default realm but use an injected test realm for current and forecast objects to write to
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "Tagaytay"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 1"))
                
                let entry = fi[0].1[0]
                expect(entry.cityid).to(equal(1684552))
                expect(entry.name).to(equal("Tagaytay City"))
                expect(entry.country).to(equal("PH"))
                expect(entry.isFavourite).to(equal(false))
                
                let tc = testController
                let selectedObject = c.filteredObjects[0].1[0]
                tc.showCurrentObject(selectedObject)
                
                expect(testRealm.objects(CurrentObject).count).toEventually( equal(1), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.cityid).toEventually( equal(1684552), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.name).toEventually( equal("Tagaytay City"), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.country).toEventually( equal("PH"), timeout: 60)
                expect(testRealm.objects(CurrentObject).first?.isFavourite).toEventually( equal(false), timeout: 60)
                
                // we can't determine exactly what's the number of forecast objects
                expect(testRealm.objects(ForecastObject).count).toEventually( beGreaterThan(0), timeout: 120)
                expect(testRealm.objects(ForecastObject).first?.cityid).toEventually( equal(1684552), timeout: 120)
            }
        }
        
        it("searches for greater london and query open weather api server") {
            if let c = defaultController {
                
                expect(testRealm.objects(CurrentObject).count).to( equal(0))
                expect(testRealm.objects(ForecastObject).count).to( equal(0))
                
                // NB. Use default realm but use an injected test realm for current and forecast objects to write to
                c.viewDidLoad()
                let bar = c.searchController.searchBar
                bar.text = "London"
                c.searchBarSearchButtonClicked(bar)
                
                let fi = c.filteredObjects
                let title = fi[0].0
                expect(title).to(equal("RESULTS - 26"))
                
                let entry = fi[0].1[1]
                expect(entry.cityid).to(equal(2648110))
                expect(entry.name).to(equal("Greater London"))
                expect(entry.country).to(equal("GB"))
                expect(entry.isFavourite).to(equal(false))
                
                let tc = testController
                let selectedObject = c.filteredObjects[0].1[0]
                tc.showCurrentObject(selectedObject)
                
                expect(testRealm.objects(CurrentObject).count).toEventually( equal(1), timeout: 60)
//                expect(testRealm.objects(CurrentObject).first?.cityid).toEventually( equal(2648110), timeout: 60)
//                expect(testRealm.objects(CurrentObject).first?.name).toEventually( equal("Greater London"), timeout: 60)
//                expect(testRealm.objects(CurrentObject).first?.country).toEventually( equal("GB"), timeout: 60)
//                expect(testRealm.objects(CurrentObject).first?.isFavourite).toEventually( equal(false), timeout: 60)
                
                // we can't determine exactly what's the number of forecast objects
                expect(testRealm.objects(ForecastObject).count).toEventually( beGreaterThan(0), timeout: 120)
//                expect(testRealm.objects(ForecastObject).first?.cityid).toEventually( equal(2648110), timeout: 120)
            }
        }
        
        it("forces to show the last test result ommitted by xcode") {
            expect(1-1).to(equal(0))
        }
    }
}

