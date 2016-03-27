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
import WatchConnectivity

class CurrentPageController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var chartImage: WKInterfaceImage!
    static var first = true
    private let session : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil

    override init() {
        super.init()
        self.session?.delegate = self
        self.session?.activateSession()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {

    }
        
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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
