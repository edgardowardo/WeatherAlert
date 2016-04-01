//
//  CurrentDetailViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import Charts
import Realm
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
    @IBOutlet weak var imageAlarmed: UIImageView!
}

class CurrentInfoView : UIView {
    @IBOutlet weak var legend1: UIView!
    @IBOutlet weak var legend2: UIView!
    @IBOutlet weak var legend3: UIView!
    @IBOutlet weak var legend4: UIView!
    @IBOutlet weak var legend1Text: UILabel!
    @IBOutlet weak var legend2Text: UILabel!
    @IBOutlet weak var legend3Text: UILabel!
    @IBOutlet weak var legend4Text: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let unit = Units(rawValue: "Metric")!
        legend1.layer.cornerRadius = legend1.frame.size.width / 2
        legend2.layer.cornerRadius = legend1.frame.size.width / 2
        legend3.layer.cornerRadius = legend1.frame.size.width / 2
        legend4.layer.cornerRadius = legend1.frame.size.width / 2
        legend1.backgroundColor = unit.getColorOfSpeed(0.0)
        legend2.backgroundColor = unit.getColorOfSpeed(7.0)
        legend3.backgroundColor = unit.getColorOfSpeed(10.0)
        legend4.backgroundColor = unit.getColorOfSpeed(16.0)

        if let u = AppObject.sharedInstance?.units {
            legend1Text.text = u.getLegendOfSpeed(.Gentle)
            legend2Text.text = u.getLegendOfSpeed(.Moderate)
            legend3Text.text = u.getLegendOfSpeed(.Fresh)
            legend4Text.text = u.getLegendOfSpeed(.Strong)
        }
    }
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
        guard let curry = current, app = AppObject.sharedInstance else { return cell }
        let t = self.forecastuples![indexPath.section]
        let f = t.2[indexPath.row]
        let speed = String(format: "%.2f", f.speedvalue)
        let temperature = String(format: "%.1f", f.temperatureValue)
        cell.imageAlarmed.hidden = !(f.isAlarmed && app.maxNotifications > 0 && curry.isFavourite)
        cell.labelHH.text = f.hour
        cell.labelSpeed.text = "\(speed)"
        cell.labelSpeed.backgroundColor = curry.units.getColorOfSpeed(f.speedvalue)
        cell.labelTemp.text = "\(temperature)°"
        if let direction = f.direction {
            cell.imageDirection.image = UIImage(named:  direction.inverse.rawValue)
        } else {
            cell.imageDirection.image = nil
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        guard let curry = current else { return UICollectionReusableView() }
        
        var cell : UICollectionReusableView
        switch kind {
        case TitlesCell.kindTableHeader :
            let t = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "LeftTitlesCellIdentifier", forIndexPath: indexPath) as! TitlesCell
            t.speedTitle.text = "Speed, \(curry.units.speed)"
            t.temperatureTitle.text = "Temperature, °\(curry.units.temperature)"
            cell = t
        case TitlesCell.kindTableFooter :
            let t = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "RightTitlesCellIdentifier", forIndexPath: indexPath) as! TitlesCell

            t.speedTitle.text = "Speed, \(curry.units.speed)"
            t.temperatureTitle.text = "Temperature, °\(curry.units.temperature)"
            cell = t
        case UICollectionElementKindSectionHeader :
            cell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayCellIdentifier", forIndexPath: indexPath)
            let forecastEntry = self.forecastuples?[indexPath.section].2[indexPath.row]
            if let c = cell as? DayCell {
                if let day = forecastEntry?.day {
                    c.text.text = day
                    if let entries = self.forecastuples?[indexPath.section].2 where day == "TODAY" && entries.count < 3 {
                        c.text.text = ""
                    }
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
            self.updateChart(withDirection: f.direction, andSpeed: f.speedvalue, andSpeedName: f.speedname, andSince: "")
        }
    }
}

class CurrentDetailViewController: UIViewController {
    
    // MARK: - Properties -

    lazy var mapNavigationViewController : UINavigationController? = self.getMapNavigationViewController()
    var delegate : MapDelegate?
    var token : RLMNotificationToken!
    let directions = Direction.directions.map({ return $0.rawValue })
    var speeds : [Double] = { return Array<Double>.init(count: 16, repeatedValue: 0.0) }()
    var current : CurrentObject?
    var since : String = ""
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
        
        if let app = AppObject.sharedInstance where app.isAdsShown {
            self.interstitialPresentationPolicy = .Automatic
        } else {
            self.interstitialPresentationPolicy = .None
        }
        token = self.getToken()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveForecastObjects:", name: ForecastObject.Notification.Identifier.didSaveForecastObjects, object: nil)
        
        radarChart.noDataText = "Wind data is still up in the air..."
        radarChart.descriptionText = ""
        radarChart.rotationEnabled = false
        radarChart.webLineWidth = 0.6
        radarChart.innerWebLineWidth = 0.0
        radarChart.webAlpha = 1.0
        radarChart.yAxis.customAxisMax = 17.0
        let gesture = UITapGestureRecognizer(target: self, action: "clickChart:")
        radarChart.addGestureRecognizer(gesture)
        
        forecastsView.delegate = self
        forecastsView.dataSource = self
        forecastsView.registerNib(UINib(nibName: "ForecastCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "LeftTitlesCell", bundle: nil), forSupplementaryViewOfKind: TitlesCell.kindTableHeader, withReuseIdentifier: "LeftTitlesCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "RightTitlesCell", bundle: nil), forSupplementaryViewOfKind: TitlesCell.kindTableFooter, withReuseIdentifier: "RightTitlesCellIdentifier")
        forecastsView.registerNib(UINib(nibName: "DayCell", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "DayCellIdentifier")
        forecastsView.contentInset = UIEdgeInsets(top: 0, left: -TitlesCell.size.width, bottom: 0, right: -TitlesCell.size.width)
        
        if let c = self.current, realm = try? Realm(), lastupdate = c.lastupdate {
            let id = "\(c.cityid)"
            self.updateChart(withDirection: c.direction, andSpeed: c.speedvalue, andSpeedName: c.speedname, andSince: "since \(lastupdate.hourAndMin)" )
            self.resetRightBarButtonItem()
            self.realmForecasts = realm.objects(ForecastObject).filter("cityid == \(id)").sorted("timefrom", ascending: true)
            self.forecastsView.reloadData()
            self.radarChart.yAxis.customAxisMax = c.units.maxSpeed
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
    
    func getToken() -> RLMNotificationToken {
        guard let realm = try? Realm() else { return token }
        token = realm.objects(AppObject).addNotificationBlock { notification, realm in
            if let app = AppObject.sharedInstance where app.isAdsShown {
                self.interstitialPresentationPolicy = .Automatic
            } else {
                self.interstitialPresentationPolicy = .None
            }
        }
        return token
    }
    
    func clickChart(sender:UITapGestureRecognizer){
        if let c = self.current, lastupdate = c.lastupdate where since.characters.count == 0 {
            self.updateChart(withDirection: c.direction, andSpeed: c.speedvalue, andSpeedName: c.speedname, andSince: "since \(lastupdate.hourAndMin)" )
        }
    }
    
    func resetRightBarButtonItem() {
        // Favourite
        var i : UIImage =  UIImage(named: "icon-star")!
        if let isFavourite = self.current?.isFavourite where isFavourite == true {
            i = UIImage(named: "icon-star-yellow")!
        }
        let star = UIButton(type: .Custom)
        star.bounds = CGRectMake(0, 0, i.size.width, i.size.height)
        star.setImage(i, forState: .Normal)
        star.addTarget(self, action: Selector("starred"), forControlEvents: .TouchUpInside)
        
        // Map
        let mapImage = UIImage(named: "icon-map")!
        let map = UIButton(type: .Custom)
        map.bounds = CGRectMake(0, 0, mapImage.size.width, mapImage.size.height)
        map.setImage(mapImage, forState: .Normal)
        map.addTarget(self, action: Selector("showMap"), forControlEvents: .TouchUpInside)
        
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: star), UIBarButtonItem(customView: map)], animated: true)
    }
    
    func showMap() {
        presentViewController(self.mapNavigationViewController!, animated: true, completion: nil)
    }
    
    func getMapNavigationViewController() -> UINavigationController {
        let vc = UIStoryboard.mapViewController()!
        vc.delegate = delegate
        vc.current = self.current
        let nav = UINavigationController(rootViewController: vc)
        return nav
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
        forecastsView.reloadData()
    }
    
    func back() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func showInfo(sender: AnyObject) {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        if let infoView = NSBundle.mainBundle().loadNibNamed("CurrentInfoView", owner: self, options: nil).first as? CurrentInfoView {
            let margin:CGFloat = 8.0
            infoView.frame =  CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4, 400.0)
            alertController.view.addSubview(infoView)
        }
        let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion:{})
    }
    
    @objc private func methodOfReceivedNotification_didSaveForecastObjects(notification : NSNotification) {
        if let cityid = notification.object as? Int, realm = try? Realm() {
            self.realmForecasts = realm.objects(ForecastObject).filter("cityid == \(cityid)").sorted("timefrom", ascending: true)
            self.forecastsView.reloadData()
        }
    }
    
    @objc private func methodOfReceivedNotification_didSaveCurrentObject(notification : NSNotification) {
        if let c = notification.object as? CurrentObject, lastupdate = c.lastupdate {
            self.current = c
            self.updateChart(withDirection: c.direction, andSpeed: c.speedvalue, andSpeedName: c.speedname, andSince: "since \(lastupdate.hourAndMin)" )
            self.resetRightBarButtonItem()
        }
    }
    
    func updateChart(withDirection direction: Direction?, andSpeed speed : Double, andSpeedName speedname : String, andSince since : String ) {
        self.since = since
        var speeds = direction?.directionsWithspeed(speed)
        if speeds == nil {
            speeds = Array<Double>.init(count: 16, repeatedValue: 0.0)
        }
        setChart(directions, values: speeds!, andDirection: direction, andSpeed: speed, andSpeedName: speedname, andSince: since)
    }
    
    func setChart(dataPoints: [String], values: [Double], andDirection direction: Direction?, andSpeed speed : Double, andSpeedName speedname : String, andSince since : String) {
       
        guard let curry = current else { return }
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0 ..< dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let speedname = ( speedname == "" ) ? "Windless" : speedname
        let directionname = ( direction == nil ) ? "nowhere" : direction!.name.lowercaseString
        let speedUnit = curry.units.speed
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "\(speedname) from \(directionname) at \(speed) \(speedUnit) \(since)")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 2.0
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        let speedColor = curry.units.getColorOfSpeed(speed)
        chartDataSet.fillColor = speedColor
        chartDataSet.setColor(speedColor, alpha: 0.6)
        let chartData = RadarChartData(xVals: directions, dataSets: [chartDataSet])
        
        radarChart.data = chartData
        radarChart.animate(yAxisDuration: NSTimeInterval(1.4), easingOption: ChartEasingOption.EaseOutBack)
    }
    
}