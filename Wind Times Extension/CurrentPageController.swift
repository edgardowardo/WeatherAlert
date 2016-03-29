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
        let items = Direction.directions.map({ element in NKRadarChartDataItem(value: CGFloat(current.speedvalue), description: element.rawValue)! })
        let chart = NKRadarChart(frame: frame, items: items, valueDivider: 1)
        chart.plotColor = UIColor.purpleColor().colorWithAlphaComponent(0.7)
        chart.fontColor = UIColor.whiteColor()
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
