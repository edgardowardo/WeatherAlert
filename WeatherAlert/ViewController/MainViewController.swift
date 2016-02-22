//
//  MainViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class MainViewController: UITableViewController {
    
    // MARK: - Properties -
    
    lazy var detailViewController: CurrentDetailViewController? = UIStoryboard.currentDetailViewController()
    lazy var favs : Results<CurrentObject> = self.getCurrents()
    var filteredFavs : [CurrentObject]!
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View lifecycle -
    
    deinit {
        if let superView = searchController.view.superview {
            superView.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Weather Alert"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "methodOfReceivedNotification_didSaveCurrentObject:", name: CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)        
        
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
    
    func getCurrents() -> Results<CurrentObject> {
        let realm = try! Realm()
        return realm.objects(CurrentObject).sorted("name", ascending: true).sorted("isFavourite", ascending: false)
    }    
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredFavs.count
        }
        return favs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let c: CurrentObject
        if searchController.active && searchController.searchBar.text != "" {
            c = filteredFavs[indexPath.row]
        } else {
            c = favs[indexPath.row]
        }
        cell.textLabel!.text = c.name
        cell.detailTextLabel!.text = c.country
        cell.accessoryType = .DisclosureIndicator
        if c.isFavourite {
            cell.imageView?.image = UIImage(named: "icon-star-yellow")
        } else {
            cell.imageView?.image = nil
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let controller = UIStoryboard.currentDetailViewController() else { return }
        
        let current: CurrentObject
        if searchController.active && searchController.searchBar.text != "" {
            current = filteredFavs[indexPath.row]
        } else {
            current = favs[indexPath.row]
        }
        
        // Current data is not stale. That is  it's less than 3 hours, show this data.
        if let lastupdate = current.lastupdate where NSDate().timeIntervalSinceDate(lastupdate) / 3600 < 3 {

            controller.title = "\(current.country), \(current.name)"
            controller.current = current
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
            self.showHud(text: "Searching...")
            Alamofire.request(Router.Search(id: current.cityid)).responseXMLDocument({ response -> Void in
                if let xml = response.result.value {
                    let xmlString = "\(xml)"
                    CurrentObject.saveXML(xmlString)
                    Alamofire.request(Router.Forecast(id: current.cityid)).responseXMLDocument({ response -> Void in
                        if let xml = response.result.value {
                            let xmlString = "\(xml)"
                            ForecastObject.saveXML(xmlString)
                            
                            self.hideHud()
                            
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
        }
    }
    
    // MARK: - Helpers -
    
    func filterContentForSearchText(searchText: String) {
        filteredFavs = Array(favs.filter("name contains '\(searchText)'"))
        tableView.reloadData()
    }
    
    @objc private func methodOfReceivedNotification_didSaveCurrentObject(notification : NSNotification) {
        if let _ = notification.object as? CurrentObject {
            favs = self.getCurrents()
            tableView.reloadData()
        }
    }
}

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
            filteredFavs = Array(cities.map({
                let c = CurrentObject()
                c.setPropertiesFromCity($0)
                return c
            }))
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

