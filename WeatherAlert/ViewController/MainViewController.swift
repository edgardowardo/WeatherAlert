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

class MainViewController: UITableViewController {
    
    // MARK: - Properties -
    
    let locationManager = CLLocationManager()
    var location : CLLocation?
    lazy var detailViewController: CurrentDetailViewController? = UIStoryboard.currentDetailViewController()
    lazy var currentObjects : [(String, [CurrentObject])] = self.getCurrentObjects()
    var filteredObjects : [(String, [CurrentObject])]!
    let searchController = UISearchController(searchResultsController: nil)
    var delegate : ContainerMenuViewDelegate?
    var token : RLMNotificationToken!
    
    // MARK: - View lifecycle -
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getToken() -> RLMNotificationToken {
        let token = try! Realm().objects(AppObject).filter("distanceKm > 0").addNotificationBlock { notification, realm in
            self.currentObjects = self.getCurrentObjects()
            self.tableView.reloadData()
        }
        return token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        token = self.getToken()
        
        if CLLocationManager.authorizationStatus() == .NotDetermined || CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
        self.title = "Weather Alert"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didLoadCityData:", name: CityObject.Notification.Identifier.didLoadCityData, object: nil)        
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search with a city name"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
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
 
    func getCurrentObjects(searchText : String? = nil) -> [(String, [CurrentObject])] {
        let realm = try! Realm()
        var currents = [(String, [CurrentObject])]()
        
        // Get favourite objects
        var favourites = realm.objects(CurrentObject).filter("isFavourite == 1")
        if let s = searchText {
            favourites = favourites.filter("name contains '\(s)'")
        }
        favourites = favourites.sorted("lastupdate", ascending: false)
        currents.append(("FAVOURITES - \(favourites.count)", Array(favourites)))
        
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
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 17)
        cell.textLabel!.text = c.name
        cell.detailTextLabel!.text = "\(c.country)\(c.distanceText)"
        cell.accessoryType = .DisclosureIndicator
        if c.isFavourite {
            cell.imageView?.image = UIImage(named: "icon-superstar")
        } else {
            cell.imageView?.image = UIImage(named: "icon-dot-fill")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let controller = UIStoryboard.currentDetailViewController() else { return }
        
        let current: CurrentObject
        if searchController.active && searchController.searchBar.text != "" {
            current = filteredObjects[indexPath.section].1[indexPath.row]
        } else {
            current = currentObjects[indexPath.section].1[indexPath.row]
        }
        
        // Current data is not stale. That is  it's less than 3 hours, show this data.
        if let lastupdate = current.lastupdate where NSDate().timeIntervalSinceDate(lastupdate) / 3600 < 3 {

            controller.title = "\(current.country), \(current.name)"
            controller.current = current
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            self.delegate?.showHud(text: "Searching...")
            Alamofire.request(Router.Search(id: current.cityid)).responseXMLDocument({ response -> Void in
                if let xml = response.result.value {
                    let xmlString = "\(xml)"
                    CurrentObject.saveXML(xmlString)
                    Alamofire.request(Router.Forecast(id: current.cityid)).responseXMLDocument({ response -> Void in
                        if let xml = response.result.value {
                            let xmlString = "\(xml)"
                            ForecastObject.saveXML(xmlString)
                            
                            self.delegate?.hideHud()
                            
                            let cityid = current.cityid
                            if let realm = try? Realm(), current = realm.objects(CurrentObject).filter("cityid == \(cityid)").first {
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
        
        let realm = try! Realm()
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

