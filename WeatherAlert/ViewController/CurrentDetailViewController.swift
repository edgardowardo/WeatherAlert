//
//  CurrentDetailViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class DayCell : UICollectionReusableView {
    static let size = CGSizeMake(110, 150)
    @IBOutlet weak var text: UILabel!
}

class TitlesCell : UICollectionReusableView {
    static let kindTableHeader = "TableHeaderKind"
    static let kindTableFooter = "TableFooterKind"
    static let size = CGSizeMake(110, 150)
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet weak var temperatureTitle: UILabel!
}

class ForecastCell : UICollectionViewCell {
    static let size = CGSizeMake(35, 150)
    static let kind = "ForecastCellKind"
    @IBOutlet weak var labelHH: UILabel!
    @IBOutlet weak var imageDirection: UIImageView!
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var labelTemp: UILabel!
}

extension CurrentDetailViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let f = self.forecastuples else { return 0 }
        return f.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let f = self.forecastuples else { return 0 }
        return f[section].2.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ForecastCellIdentifier", forIndexPath: indexPath) as! ForecastCell
        let t = self.forecastuples![indexPath.section]
        let f = t.2[indexPath.row]
        let speed = String(format: "%.2f", f.speedvalue)
        let temperature = String(format: "%.1f", f.temperatureValue)
        cell.labelHH.text = f.hour
        cell.labelSpeed.text = "\(speed)"
        cell.labelSpeed.backgroundColor = UIColor.getColorOfSpeed(f.speedvalue)
        cell.labelTemp.text = "\(temperature)°"
        if f.directioncode.characters.count > 0 {
            cell.imageDirection.image = UIImage(named: f.directioncode)
        } else {
            cell.imageDirection.image = nil
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var cell : UICollectionReusableView
        switch kind {
        case TitlesCell.kindTableHeader :
            cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "LeftTitlesCellIdentifier", forIndexPath: indexPath) as! TitlesCell
        case TitlesCell.kindTableFooter :
            cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "RightTitlesCellIdentifier", forIndexPath: indexPath) as! TitlesCell
        case UICollectionElementKindSectionHeader :
            cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayCellIdentifier", forIndexPath: indexPath)
            let forecastEntry = self.forecastuples?[indexPath.section].2[indexPath.row]
            if let c = cell as? DayCell {
                if let day = forecastEntry?.day, hour = forecastEntry?.hour  where Int(hour) < 21 {
                    c.text.text = day
                } else {
                    c.text.text = ""
                }
            }
        default :
            cell = UICollectionReusableView()
        }
        return cell
    }
}


extension CurrentDetailViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let f = self.forecastuples?[indexPath.section].2[indexPath.row] {
            self.updateChart(withDirectionCode: f.directioncode, andDirectionName: f.directionname, andSpeed: f.speedvalue, andSpeedName: f.speedname, andSince: "")
        }
    }
}

class CurrentDetailViewController: UIViewController {
    
    // MARK: - Properties -
    
    let directions : [String] = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW" ]
    var speeds : [Double] = { return Array<Double>.init(count: 16, repeatedValue: 0.0) }()
    var current : CurrentObject?
    @IBOutlet weak var radarChart: RadarChartView!
    @IBOutlet weak var forecastsView: UICollectionView!
    var forecastuples : [(String, NSDate, [ForecastObject])]?
    var realmForecasts : Results<ForecastObject>? {
        didSet {
            let sections = Set( realmForecasts!.valueForKey("day") as! [String])
            forecastuples = []
            for s in sections {
                if let perdays = realmForecasts?.filter({ s == $0.day }).sort({ $0.timefrom!.compare($1.timefrom!) == .OrderedAscending }), f = perdays.first, date = f.date {
                    forecastuples!.append( (s, date, perdays))
                }
            }
            forecastuples?.sortInPlace({ $0.1.compare($1.1) == .OrderedAscending })
        }
    }
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveForecastObjects:", name: ForecastObject.Notification.Identifier.didSaveForecastObjects, object: nil)
        
        radarChart.noDataText = "Wind data is still up in the air..."
        radarChart.descriptionText = ""
        radarChart.rotationEnabled = false
        radarChart.webLineWidth = 0.6
        radarChart.innerWebLineWidth = 0.0
        radarChart.webAlpha = 1.0
        radarChart.yAxis.customAxisMax = 17.0
        
        forecastsView.delegate = self
        forecastsView.dataSource = self
        forecastsView.registerNib(UINib(nibName: "ForecastCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "LeftTitlesCell", bundle: nil), forSupplementaryViewOfKind: TitlesCell.kindTableHeader, withReuseIdentifier: "LeftTitlesCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "RightTitlesCell", bundle: nil), forSupplementaryViewOfKind: TitlesCell.kindTableFooter, withReuseIdentifier: "RightTitlesCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "DayCell", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "DayCellIdentifier")
        forecastsView.contentInset = UIEdgeInsets(top: 0, left: -TitlesCell.size.width, bottom: 0, right: -TitlesCell.size.width)
        
        if let c = self.current, realm = try? Realm() {
            let id = "\(c.cityid)"
            self.updateChart(withDirectionCode: c.directioncode, andDirectionName: c.directionname, andSpeed: c.speedvalue, andSpeedName: c.speedname, andSince: "since \(c.hourAndMin)" )
            self.resetRightBarButtonItem()
            self.realmForecasts = realm.objects(ForecastObject).filter("cityid == \(id)").sorted("timefrom", ascending: true)
            self.forecastsView.reloadData()
        }
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
        
        resetRightBarButtonItem()
    }
    
    // MARK: - Helpers -
    
    func resetRightBarButtonItem() {        
        var i : UIImage =  UIImage(named: "icon-star")!
        if let isFavourite = self.current?.isFavourite where isFavourite == true {
            i = UIImage(named: "icon-star-yellow")!
        }
        let star = UIButton(type: .Custom)
        star.bounds = CGRectMake(0, 0, i.size.width, i.size.height)
        star.setImage(i, forState: .Normal)
        star.addTarget(self, action: Selector("starred"), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: star)
    }
    
    func starred() {
        guard let c = self.current else { return }
        
        let realm = try! Realm()
        try! realm.write {
            let f = realm.objects(CurrentObject).filter("cityid == \(c.cityid)").first!
            f.isFavourite = !f.isFavourite
            NSNotificationCenter.defaultCenter().postNotificationName(CurrentObject.Notification.Identifier.didSaveCurrentObject, object: c)
        }
        resetRightBarButtonItem()
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @objc private func methodOfReceivedNotification_didSaveForecastObjects(notification : NSNotification) {
        if let cityid = notification.object as? Int, realm = try? Realm() {
            self.realmForecasts = realm.objects(ForecastObject).filter("cityid == \(cityid)").sorted("timefrom", ascending: true)
            self.forecastsView.reloadData()
        }
    }
    
    @objc private func methodOfReceivedNotification_didSaveCurrentObject(notification : NSNotification) {
        if let c = notification.object as? CurrentObject {
            self.current = c
            self.updateChart(withDirectionCode: c.directioncode, andDirectionName: c.directionname, andSpeed: c.speedvalue, andSpeedName: c.speedname, andSince: "since \(c.hourAndMin)" )
            self.resetRightBarButtonItem()
        }
    }
    
    func updateChart(withDirectionCode code : String, andDirectionName directionname : String, andSpeed speed : Double, andSpeedName speedname : String, andSince since : String ) {

        self.speeds = Array<Double>.init(count: 16, repeatedValue: 0.0)
        
        if let index = directions.indexOf(code) {
            
            if index == 0 {
                speeds[directions.count-1] = speed
            } else {
                speeds[index-1] = speed
            }
            
            if index == directions.count-1 {
                speeds[0] = speed
            } else {
                speeds[index + 1] = speed
            }
            
            speeds[index] = speed
        }
        setChart(directions, values: speeds, andDirectionName: directionname, andSpeed: speed, andSpeedName: speedname, andSince: since)
    }
    
    func setChart(dataPoints: [String], values: [Double], andDirectionName directionname1 : String, andSpeed speed : Double, andSpeedName speedname : String, andSince since : String) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0 ..< dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let speedname = ( speedname == "" ) ? "Windless" : speedname
        let directionname = ( directionname1 == "" ) ? "nowhere" : directionname1.lowercaseString
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "\(speedname) towards \(directionname) at \(speed) m/s \(since)")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        let speedColor = UIColor.getColorOfSpeed(speed)
        chartDataSet.fillColor = speedColor
        chartDataSet.setColor(speedColor, alpha: 0.6)
        let chartData = RadarChartData(xVals: directions, dataSets: [chartDataSet])
        
        radarChart.data = chartData
        radarChart.animate(yAxisDuration: NSTimeInterval(1.4), easingOption: ChartEasingOption.EaseOutBack)
    }
    
}