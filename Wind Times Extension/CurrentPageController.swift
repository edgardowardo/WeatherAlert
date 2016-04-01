//
//  InterfaceController.swift
//  Wind Times Extension
//
//  Created by EDGARDO AGNO on 25/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import WatchKit
import Foundation
import NKWatchChart

class DayRow : NSObject {
    @IBOutlet var dayLabel: WKInterfaceLabel!
}

class ForecastRow : NSObject {    
    @IBOutlet var hour: WKInterfaceLabel!
    @IBOutlet var directionImage: WKInterfaceImage!
    @IBOutlet var directionGroup : WKInterfaceGroup!
    @IBOutlet var speedValue: WKInterfaceLabel!
    @IBOutlet var speedName: WKInterfaceLabel!
}

class CurrentPageController: WKInterfaceController, DataSourceChangedDelegate {

    var current : CurrentObject? = nil
    @IBOutlet var chartImage: WKInterfaceImage!
    @IBOutlet var currentLabel: WKInterfaceLabel!
    @IBOutlet var forecastsLabel: WKInterfaceLabel!    
    @IBOutlet var table: WKInterfaceTable!
    
    func dataSourceDidUpdate(dataSource: DataSource) {

        guard let currents = dataSource.currentObjects where currents.count > 0 else {
            WKInterfaceController.reloadRootControllersWithNames(["CurrentPageController"], contexts: [])
            return
        }
        let names = Array(count: currents.count, repeatedValue: "CurrentPageController")
        WKInterfaceController.reloadRootControllersWithNames(names, contexts: currents)
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        //NSLog("log-awakeWithContext")
        
        guard let current = context as? CurrentObject else { return }
        
        self.current = current
        
        // Build the chart image
        
        let frame = CGRectMake(0, 0, self.contentFrame.size.width, self.contentFrame.size.height)
        var items = Direction.directions.map({ element in NKRadarChartDataItem(value: 0.0, description: element.rawValue)! })
        if let dir = current.direction {
            for (index, element) in dir.directionsWithspeed(current.speedvalue).enumerate() {
                items[index].value = CGFloat(element)
            }
        }
        items.shiftRightInPlace(4)
        let chart = NKRadarChart(frame: frame, items: items, valueDivider: 1)
        chart.plotColor = current.units.getColorOfSpeed(current.speedvalue).colorWithAlphaComponent(0.7)
        chart.fontColor = UIColor.whiteColor()
        chart.maxValue = CGFloat(current.units.maxSpeed)
        chartImage.setImage(chart.drawImage())
        
        self.setTitle(current.name)

        // Build the forecast row types
        
        var rowTypeWithForecasts = [(String, ForecastObject)]()
        var currentday = ""
        for f in current.forecasts {
            if currentday != f.day {
                currentday = f.day
                rowTypeWithForecasts.append(("DayRow", f))
            }
            rowTypeWithForecasts.append(("ForecastRow", f))
        }
        let rowTypes = rowTypeWithForecasts.map({ (rowType, forecast) in return rowType })
        table.setRowTypes(rowTypes)
        
        // Bind the row data
        
        for (index, element) in rowTypeWithForecasts.enumerate() {
            let forecast = element.1
            if let forecastRow = table.rowControllerAtIndex(index) as? ForecastRow {
                if let invertedDirectionCode = forecast.direction?.inverse.rawValue {
                    forecastRow.directionImage.setImageNamed("\(invertedDirectionCode)-white")
                    forecastRow.directionGroup.setBackgroundColor(current.units.getColorOfSpeed(forecast.speedvalue))
                }
                forecastRow.hour.setText("\(forecast.hour)h")
                forecastRow.speedValue.setText("\(forecast.speedvalue)")
                forecastRow.speedValue.setTextColor(current.units.getColorOfSpeed(forecast.speedvalue))
            } else if let dayRow = table.rowControllerAtIndex(index) as? DayRow {
                dayRow.dayLabel.setText(forecast.day)
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user

        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        super.willActivate()
        //NSLog("log-willActivate")
        
        guard let current = self.current, lastupdate = current.lastupdate else {
            chartImage.setHidden(true)
            currentLabel.setText("Please add favourites from the main app.")
            forecastsLabel.setText("")
            return
        }
        chartImage.setHidden(false)
        currentLabel.setText("\(current.speedname) \(lastupdate.hourAndMin)")
        forecastsLabel.setText("FORECASTS")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        
        WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
        super.didDeactivate()
    }
    
}
