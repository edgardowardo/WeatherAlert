//
//  CurrentDetailViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import Charts

class CurrentDetailViewController: UIViewController {
    
    // MARK: - Properties -
    
    let directions : [String] = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" ]
    var speeds : [Double] = { return Array<Double>.init(count: 16, repeatedValue: 0.0) }()
    var current : CurrentObject?
    @IBOutlet weak var radarChart: RadarChartView!
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
        
        radarChart.noDataText = "Wind data is still up in the air..."
        radarChart.descriptionText = ""
        radarChart.rotationEnabled = false
        radarChart.webLineWidth = 0.6
        radarChart.innerWebLineWidth = 0.0
        radarChart.webAlpha = 1.0
        radarChart.yAxis.customAxisMax = 17.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
        
        let leftButton : UIBarButtonItem = UIBarButtonItem(image : UIImage(named: "icon-arrow-left"), style: .Done, target: self, action: Selector("back"))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(image : UIImage(named: "icon-star"), style: .Done, target: self, action: Selector("starred"))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - Helpers -
    
    func starred() {
        
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @objc private func methodOfReceivedNotification_didSaveCurrentObject(notification : NSNotification) {
        if let c = notification.object as? CurrentObject {
            self.current = c
            if let index = directions.indexOf(c.directioncode) {
                
                if index == 0 {
                    speeds[directions.count-1] = c.speedvalue
                } else {
                    speeds[index-1] = c.speedvalue
                }
                
                if index == directions.count-1 {
                    speeds[0] = c.speedvalue
                } else {
                    speeds[index + 1] = c.speedvalue
                }
                
                speeds[index] = c.speedvalue
            }
            setChart(directions, values: speeds)
        }
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        guard let c = self.current else { return }
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0 ..< dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "\(c.speedname) from \(c.directionname.lowercaseString) at \(c.speedvalue) m/s")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawFilledEnabled = true
        if let c = self.current {
            let speedColor = UIColor.getColorOfSpeed(c.speedvalue)
            chartDataSet.fillColor = speedColor
            chartDataSet.setColor(speedColor, alpha: 0.6)
            
        }
        let chartData = RadarChartData(xVals: directions, dataSets: [chartDataSet])
        
        radarChart.data = chartData
        radarChart.animate(yAxisDuration: NSTimeInterval(1.4), easingOption: ChartEasingOption.EaseOutBack)
    }
    
}