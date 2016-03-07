//
//  WeatherAlertUITests.swift
//  WeatherAlertUITests
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import XCTest

/*
NB: I couldn't setup Quick and Nimble with UI Tests. The application was not loading when configured with Q&N. And it's late. So I opted to use the classic way.
*/

class WeatherAlertUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_01_search_city_leeds() {
        app.tables.searchFields["Search with a city name"].tap()
        app.searchFields["Search with a city name"].typeText("Leeds")
        app.keyboards.buttons["Search"].tap()
        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 10, "found instead: \(cells.debugDescription)")
    }
    
    func test_02_search_city_manchester() {
        app.tables.searchFields["Search with a city name"].tap()
        app.searchFields["Search with a city name"].typeText("Manchester")
        app.keyboards.buttons["Search"].tap()
        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 25, "found instead: \(cells.debugDescription)")
    }
    
    func test_03_search_city_tagaytay() {
        app.tables.searchFields["Search with a city name"].tap()
        app.searchFields["Search with a city name"].typeText("Tagaytay")
        app.keyboards.buttons["Search"].tap()
        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 6, "found instead: \(cells.debugDescription)")
    }

    func test_04_search_city_london() {
        app.tables.searchFields["Search with a city name"].tap()
        app.searchFields["Search with a city name"].typeText("London")
        app.keyboards.buttons["Search"].tap()
        let cells = app.tables.cells
        XCTAssertEqual(cells.count, 31, "found instead: \(cells.debugDescription)")
    }
}


