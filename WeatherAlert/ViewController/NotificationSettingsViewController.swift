//
//  NotificationSettingsViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 23/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import UIKit
import TTRangeSlider
import AKPickerView
import Charts

class NotificationSettingsViewController : UIViewController {
    
    // MARK: - Properties -
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var percityTitle: UILabel!
    @IBOutlet weak var percitySlider: TTRangeSlider!
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet weak var speedSlider: TTRangeSlider!
    @IBOutlet weak var directionTitle: UILabel!
    @IBOutlet weak var startDirection: AKPickerView!
    @IBOutlet weak var endDirection: AKPickerView!
    @IBOutlet weak var radarChart: RadarChartView!
    let directions = Direction.directions
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        startDirection.delegate = self
        startDirection.dataSource = self
        startDirection.fisheyeFactor = 0.001
        endDirection.delegate = self
        endDirection.dataSource = self
        endDirection.fisheyeFactor = 0.001
        
        if let app = AppObject.sharedInstance {
            speedSlider.tintColor = app.units.getColorOfSpeed(app.speedMin)
            speedSlider.delegate = self
            speedSlider.maxValue = Float(app.units.maxSpeed)
            speedTitle.text = "Speed (max \(Int(app.units.maxSpeed))\(app.units.speed) or faster)"
            speedSlider.selectedMinimum = Float(app.speedMin)
            speedSlider.selectedMaximum = Float(app.speedMax)
            if app.units == .Imperial {
                speedSlider.selectedMinimum = Float(app.units.toMph(app.speedMin))
                speedSlider.selectedMaximum = Float(app.units.toMph(app.speedMax))
            }
            let start = app.directionCodeStart
            let end = app.directionCodeEnd
            directionTitle.text =  ( start == end ) ? "Direction towards \(start) " : "Directions between \(start) & \(end)"
            
            if let dir = Direction(rawValue: app.directionCodeStart), index = directions.indexOf(dir) {
                startDirection.selectItem(UInt(index.hashValue), animated: false)
            }
            if let dir = Direction(rawValue: app.directionCodeEnd), index = directions.indexOf(dir) {
                endDirection.selectItem(UInt(index.hashValue), animated: false)
            }
        }
        
        startDirection.reloadData()
        endDirection.reloadData()
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        resetAllowTitle()        
    }
    
    // MARK: - Helpers  -
    
    func resetAlarm() {
//        NotificationObject.resetAlarm()
        resetAllowTitle()
    }
    
    func resetAllowTitle() {
        if let count = UIApplication.sharedApplication().scheduledLocalNotifications?.count {
            percityTitle.text = "Notifications per city (\(count) total)"
        }
    }
    
}

extension NotificationSettingsViewController : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView!) -> UInt {
        return UInt(directions.count)
    }
    
    func pickerView(pickerView: AKPickerView!, imageForItem item: Int) -> UIImage! {
        return UIImage(named: directions[item].rawValue )
    }
    
}

extension NotificationSettingsViewController : AKPickerViewDelegate {
    
    func pickerView(pickerView: AKPickerView!, didSelectItem item: Int) {
        let start = self.directions[Int(startDirection.selectedItem)].rawValue
        let end = self.directions[Int(endDirection.selectedItem)].rawValue
        directionTitle.text =  ( start == end ) ? "Direction towards \(start) " : "Directions between \(start) & \(end)"
        if let app = AppObject.sharedInstance {
            let code = directions[Int(pickerView.selectedItem)].rawValue
            if pickerView == startDirection {
                app.directionCodeStart =  code
            }
            if pickerView == endDirection {
                app.directionCodeEnd =  code
            }
        }
        resetAlarm()
    }
    
}

extension NotificationSettingsViewController : TTRangeSliderDelegate {
    
    func rangeSlider(sender: TTRangeSlider!, didChangeSelectedMinimumValue selectedMinimum: Float, andMaximumValue selectedMaximum: Float) {
        var min = Double(selectedMinimum)
        var max = Double(selectedMaximum)
        if let app = AppObject.sharedInstance where app.units == .Imperial {
            min = app.units.toMs(min)
            max = app.units.toMs(max)
        }
        AppObject.sharedInstance?.speedMin = min
        AppObject.sharedInstance?.speedMax = max
        
        let slider = sender as TTRangeSlider
        slider.tintColor = AppObject.sharedInstance?.units.getColorOfSpeed(Double(selectedMinimum))
        
        resetAlarm()
    }
}

