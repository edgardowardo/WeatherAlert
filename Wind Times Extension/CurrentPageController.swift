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

class CurrentPageController: WKInterfaceController, DataSourceChangedDelegate {

    @IBOutlet var chartImage: WKInterfaceImage!
    
    func dataSourceDidUpdate(dataSource: DataSource) {

        guard let currents = dataSource.currentObjects else { return }
        let names = Array(count: currents.count, repeatedValue: "CurrentPageController")
        WKInterfaceController.reloadRootControllersWithNames(names, contexts: currents)
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        
        guard let current = context as? CurrentObject else { return }
        
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
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
        super.didDeactivate()
    }
    
}
