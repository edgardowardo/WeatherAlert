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
        
        let controller = UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("MainViewController") as? MainViewController
        
        beforeEach {
        }
        
        afterEach {
        }
        
        it("filters for leeds") {
            if let c = controller {
                let currents = c.getCurrentObjects("Leeds")
                expect(currents.count).to(equal(2))
                expect(currents[0].0).to(equal("FAVOURITES - 0"))
                expect(currents[1].0).to(equal("RECENTS - 0"))
            }
        }
        
        it("searches for leeds") {
            if let c = controller {
                
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
            if let c = controller {
                
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
            if let c = controller {
                
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
            if let c = controller {
                
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
        
    }
}

