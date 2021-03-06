//
//  MainViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Alamofire
import CoreLocation
import iAd

class MainViewController: UITableViewController {
    
    // MARK: - Properties -
    
    var realm : Realm! = nil
    let locationManager = CLLocationManager()
    var location : CLLocation?
    lazy var detailViewController: CurrentDetailViewController? = UIStoryboard.currentDetailViewController()
    lazy var currentObjects : [(String, [CurrentObject])] = self.getCurrentObjects()
    var filteredObjects : [(String, [CurrentObject])]!
    let searchController = UISearchController(searchResultsController: nil)
    var delegate : ContainerMenuViewDelegate?
    var token : RLMNotificationToken!
    var tokenCurrents : RLMNotificationToken!
    var mapNavigationViewController : UINavigationController? {
        get {
            return getMapNavigationViewController()
        }
    }
    
    // MARK: - View lifecycle -
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getToken() -> RLMNotificationToken {
        token = realm.objects(AppObject).addNotificationBlock { notification, realm in
            if let app = AppObject.sharedInstance {
                self.canDisplayBannerAds = app.isAdsShown
            }
            self.currentObjects = self.getCurrentObjects()
            self.tableView.reloadData()
        }
        return token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if realm == nil {
            realm = try! Realm()
        }
        token = self.getToken()
        tokenCurrents = realm.objects(CurrentObject).addNotificationBlock { notification, realm in
            self.tableView.reloadData()
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
        if let app = AppObject.sharedInstance {
            self.canDisplayBannerAds = app.isAdsShown
        }
        self.title = "Wind Times"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didLoadCityData:", name: CityObject.Notification.Identifier.didLoadCityData, object: nil)        
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search with a city name"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        if let _ = self.location {
            resetRightBarButtonItem()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    
    // MARK: - Helpers -
    
    func resetRightBarButtonItem() {
        let i : UIImage =  UIImage(named: "icon-map")!
        let map = UIButton(type: .Custom)
        map.bounds = CGRectMake(0, 0, i.size.width, i.size.height)
        map.setImage(i, forState: .Normal)
        map.addTarget(self, action: Selector("openMap"), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: map)
    }
    
    func openMap() {
        presentViewController(self.mapNavigationViewController!, animated: true, completion: nil)
    }
    
    func getMapNavigationViewController() -> UINavigationController {
        let vc = UIStoryboard.mapViewController()!
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    
    func getNearbies(fromLocation location: CLLocation?, andSearchText searchText : String?) -> [CurrentObject] {
        if let loc = location, app = AppObject.sharedInstance {
            let latitude = loc.coordinate.latitude, longitude = loc.coordinate.longitude
            let searchDistance = app.distanceKm
            let minLat = latitude - (searchDistance / 69)
            let maxLat = latitude + (searchDistance / 69)
            let minLon = longitude - searchDistance / fabs(cos(latitude.degreesToRadians)*69)
            let maxLon = longitude + searchDistance / fabs(cos(latitude.degreesToRadians)*69)
            let predicate = "lat <= \(maxLat) AND lat >= \(minLat) AND lon <= \(maxLon) AND lon >= \(minLon)"
            var nearbyCities = realm.objects(CityObject).filter(predicate)
            if let s = searchText {
                nearbyCities = nearbyCities.filter("name contains '\(s)'")
            }
            var nearbies = nearbyCities.map({
                return CurrentObject().setPropertiesFromCity($0, currentLocation: loc)
            })
            nearbies.sortInPlace({ return $0.0.distanceKm < $0.1.distanceKm })
            return nearbies
        }
        return []
    }
    
    func getCurrentObjects(searchText : String? = nil) -> [(String, [CurrentObject])] {
        var currents = [(String, [CurrentObject])]()
        
        // Get favourite objects
        var favourites = realm.objects(CurrentObject).filter("isFavourite == 1")
        if let s = searchText {
            favourites = favourites.filter("name contains '\(s)'")
        }
        favourites = favourites.sorted("lastupdate", ascending: false)
        currents.append(("FAVOURITES - \(favourites.count)", Array(favourites)))
        
        if let loc = location {
            let nearbies = getNearbies(fromLocation: loc, andSearchText: searchText)
            currents.append(("NEARBY - \(nearbies.count)", Array(nearbies)))
        }
        
        // Get recent objects
        var recents = realm.objects(CurrentObject).filter("isFavourite == 0")
        if let s = searchText {
            recents = recents.filter("name contains '\(s)'")
        }
        recents = recents.sorted("lastupdate", ascending: false)
        currents.append(("RECENTS - \(recents.count)", Array(recents)))
        return currents
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredObjects.count
        }
        return currentObjects.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredObjects[section].1.count
        }
        return currentObjects[section].1.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let c: CurrentObject
        if searchController.active && searchController.searchBar.text != "" {
            c = filteredObjects[indexPath.section].1[indexPath.row]
        } else {
            c = currentObjects[indexPath.section].1[indexPath.row]
        }
        if let loc = self.location {
            c.currentLocation = loc
        }
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 17)
        cell.textLabel!.text = c.name
        cell.detailTextLabel!.text = "\(c.country)\(c.distanceText)"
        cell.accessoryType = .DisclosureIndicator
        if c.isFavourite {
            if c.isComplicated {
                cell.imageView?.image = UIImage(named: "icon-watch-yellow")
            } else {
                cell.imageView?.image = UIImage(named: "icon-superstar")
            }
        } else {
            cell.imageView?.image = UIImage(named: "icon-dot-fill")
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var current: CurrentObject
        if searchController.active && searchController.searchBar.text != "" {
            current = filteredObjects[indexPath.section].1[indexPath.row]
        } else {
            current = currentObjects[indexPath.section].1[indexPath.row]
        }
        
        showCurrentObject(current)
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredObjects[section].0
        }
        return currentObjects[section].0
    }
    
    // MARK: - Helpers -
    
    func filterContentForSearchText(searchText: String) {
        filteredObjects = self.getCurrentObjects(searchText)
        tableView.reloadData()
    }
    
    @objc private func methodOfReceivedNotification_didSaveCurrentObject(notification : NSNotification) {
        currentObjects = self.getCurrentObjects()
        tableView.reloadData()
    }

    @objc private func methodOfReceivedNotification_didLoadCityData(notification : NSNotification) {
        currentObjects = self.getCurrentObjects()
        tableView.reloadData()
    }
}

// MARK: - Map Delegate -

extension MainViewController : MapDelegate {
    
    func showCurrentObject(var current : CurrentObject) {
        guard let _ = realm, controller = UIStoryboard.currentDetailViewController() else { return }
        controller.delegate = self
        
        if let first = realm.objects(CurrentObject).filter("cityid == \(current.cityid)").first where current.lastupdate == nil {
            current = first
        }
        
        // Current data is not stale. That is  it's less than 3 hours, show this data.
        if let lastupdate = current.lastupdate where NSDate().timeIntervalSinceDate(lastupdate) / 3600 < NSDate().hoursIntervalForSearch {
            
            controller.title = "\(current.country), \(current.name)"
            controller.current = current
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            self.delegate?.showHud(text: "Searching...")
            Alamofire.request(Router.Search(id: current.cityid)).responseXMLDocument({ response -> Void in
                if let xml = response.result.value {
                    let xmlString = "\(xml)"
                    CurrentObject.saveXML(xmlString, realm: self.realm)
                    Alamofire.request(Router.Forecast(id: current.cityid)).responseXMLDocument({ response -> Void in
                        if let xml = response.result.value {
                            let xmlString = "\(xml)"
                            ForecastObject.saveXML(xmlString, realm: self.realm)
                            
                            self.delegate?.hideHud()
                            
                            let cityid = current.cityid
                            if let current = self.realm.objects(CurrentObject).filter("cityid == \(cityid)").first {
                                controller.title = "\(current.country), \(current.name)"
                                controller.current = current
                                self.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    })
                }
            })
            UIApplication.delay(5, closure: { () -> () in
                self.delegate?.hideHud()
            })
        }
    }

    func getNearbies(fromLocation location: CLLocation?) -> [CurrentObject] {
        let nearbies = getNearbies(fromLocation: location, andSearchText: nil)
        return swapCachedNearbies(nearbies)
    }    
    
    func swapCachedNearbies(nearbies : [CurrentObject]) -> [CurrentObject] {
        let cachedCities = realm.objects(CurrentObject)
        let nearbyCurrents = nearbies.map({ (c : CurrentObject) -> CurrentObject in
            let id = c.cityid
            if let first = cachedCities.filter({ $0.cityid == id }).first {
                return first
            } else {
                return c
            }
        })
        return nearbyCurrents
    }
    
    func getDeviceLocation() -> CLLocation? {
        return self.location
    }
}

// MARK: - Core Location -

extension MainViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            currentObjects = getCurrentObjects()
            tableView.reloadData()
            locationManager.stopUpdatingLocation()
            resetRightBarButtonItem()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
    }
}


// MARK: - Search Bar Delegate -

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        
        let cities = realm.objects(CityObject).filter("name contains '\(searchText)'")
        
        if cities.count == 0 {
            searchBar.text = nil
            let a = UIAlertController(title: "Unknown city", message: "Your search criteria did not return results. Please search again.", preferredStyle: UIAlertControllerStyle.Alert)
            a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(a, animated: true, completion: nil)
        } else {
            var currents = [(String, [CurrentObject])]()
            let results = Array(cities.map({
                return CurrentObject().setPropertiesFromCity($0)
            }))
            currents.append(("RESULTS - \(results.count)", results))
            filteredObjects = currents
            tableView.reloadData()
        }
    }
    
}

// MARK: - UISearchResultsUpdating Delegate -

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

