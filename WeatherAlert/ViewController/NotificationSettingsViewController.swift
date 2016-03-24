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
    let directionsEnum = Direction.directions
    let directions = Direction.directions.map({ return $0.rawValue })
    
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
            
            if let dir = Direction(rawValue: app.directionCodeStart), index = directionsEnum.indexOf(dir) {
                startDirection.selectItem(UInt(index.hashValue), animated: false)
            }
            if let dir = Direction(rawValue: app.directionCodeEnd), index = directionsEnum.indexOf(dir) {
                endDirection.selectItem(UInt(index.hashValue), animated: false)
            }
            
            radarChart.yAxis.customAxisMax = app.units.maxSpeed
        }
        
        startDirection.reloadData()
        endDirection.reloadData()
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        resetAllowTitle()
        
        // radar chart
        
        radarChart.noDataText = "Wind data is still up in the air..."
        radarChart.descriptionText = ""
        radarChart.rotationEnabled = false
        radarChart.webLineWidth = 0.6
        radarChart.innerWebLineWidth = 0.0
        radarChart.webAlpha = 1.0
        radarChart.legendRenderer.legend = nil
        radarChart.yAxis.drawLabelsEnabled = false
    }
    
    // MARK: - Helpers  -
    
    func resetAlarm() {
        updateChart()
//        NotificationObject.resetAlarm()
        resetAllowTitle()
    }
    
    func resetAllowTitle() {
        if let count = UIApplication.sharedApplication().scheduledLocalNotifications?.count {
            percityTitle.text = "Notifications per city (\(count) total)"
        }
    }
    
    func updateChart() {
        guard let app = AppObject.sharedInstance else { return }
        let appliedCodes = app.getCodes()
        let speed = Double(app.speedMin)
        
        let speeds = directions.map({ dir -> Double in
            if let _ = appliedCodes.filter({ $0 == dir }).first {
                return speed
            }
            return 0.0
        })
        setChart(directions, values: speeds, andSpeed: speed)
    }
    
    func setChart(dataPoints: [String], values: [Double], andSpeed speed : Double) {
        
        guard let app = AppObject.sharedInstance else { return }
        let dataEntries = values.enumerate().map({ (index, element) in return ChartDataEntry(value: element, xIndex: index)  })
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: nil)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        let speedColor = app.units.getColorOfSpeed(speed)
        chartDataSet.fillColor = speedColor
        chartDataSet.setColor(speedColor, alpha: 0.6)
        let chartData = RadarChartData(xVals: directions, dataSets: [chartDataSet])
        
        radarChart.data = chartData
        radarChart.animate(yAxisDuration: NSTimeInterval(1.4), easingOption: ChartEasingOption.EaseOutBack)
    }
}

extension NotificationSettingsViewController : AKPickerViewDataSource {
    
    func numberOfItemsInPickerView(pickerView: AKPickerView!) -> UInt {
        return UInt(directions.count)
    }
    
    func pickerView(pickerView: AKPickerView!, imageForItem item: Int) -> UIImage! {
        return UIImage(named: directionsEnum[item].rawValue )
    }
    
}

extension NotificationSettingsViewController : AKPickerViewDelegate {
    
    func pickerView(pickerView: AKPickerView!, didSelectItem item: Int) {
        let start = self.directionsEnum[Int(startDirection.selectedItem)].rawValue
        let end = self.directionsEnum[Int(endDirection.selectedItem)].rawValue
        directionTitle.text =  ( start == end ) ? "Direction towards \(start) " : "Directions between \(start) & \(end)"
        if let app = AppObject.sharedInstance {
            let code = directionsEnum[Int(pickerView.selectedItem)].rawValue
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

