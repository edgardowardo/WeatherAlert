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

class CurrentPageController: WKInterfaceController {

    @IBOutlet var chartImage: WKInterfaceImage!
    static var first = true
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        WatchSessionManager.sharedManager.session?.sendMessage(["command" : "getFavourites"], replyHandler: { (data : [String : AnyObject]) -> Void in
            NSLog("replyHandler \(data)")
            }, errorHandler: nil)
        
//        if CurrentPageController.first {
//            WKInterfaceController.reloadRootControllersWithNames(["CurrentPageController", "CurrentPageController", "CurrentPageController"], contexts: ["first", "second", "third"])
//            CurrentPageController.first = false
//        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let frame = CGRectMake(0, 0, self.contentFrame.size.width, self.contentFrame.size.height)
        let items = Direction.directions.map({ element in NKRadarChartDataItem(value: 5.0, description: element.rawValue)! })
        let chart = NKRadarChart(frame: frame, items: items, valueDivider: 1)
        
        chartImage.setImage(chart.drawImage())
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
