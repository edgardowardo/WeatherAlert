//
//  MapViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 14/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import MapKit
import UIKit

protocol MapDelegate {
    func getNearbies(fromLocation location: CLLocation?) -> [CurrentObject]
    func getDeviceLocation() -> CLLocation?
    func showCurrentObject(var current : CurrentObject)
}

class MapViewController: UIViewController {
    
    // MARK: - Properties -
    
    var current : CurrentObject?
    var delegate : MapDelegate?
    @IBOutlet weak var map: MKMapView!
    private var mapChangedFromUserInteraction = false
    private var selectedCurrentObject : CurrentObject? = nil
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.presentingViewController {
            if self == (self.navigationController?.viewControllers.first!)! as UIViewController {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("close:"))
            }
        }

        map.delegate = self
        map.zoomEnabled = false
        map.showsUserLocation = true
        map.rotateEnabled = false
        
        resetRightBarButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let location = current?.location, nearby = delegate?.getNearbies(fromLocation: location)  {
            resetMapAnnotations(map, nearby : nearby, andRegion: true)
        } else if let location = delegate?.getDeviceLocation(), nearby = delegate?.getNearbies(fromLocation: location) {
            resetMapAnnotations(map, nearby : nearby, andRegion: true)
        }
    }
    
    // MARK: - Helpers  -
    
    func resetRightBarButtonItem() {
        if let _ = delegate?.getDeviceLocation() {
            let i : UIImage =  UIImage(named: "icon-target")!
            let map = UIButton(type: .Custom)
            map.bounds = CGRectMake(0, 0, i.size.width, i.size.height)
            map.setImage(i, forState: .Normal)
            map.addTarget(self, action: Selector("refocus:"), forControlEvents: .TouchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: map)
        }
    }
    
    func refocus(sender: AnyObject) {
        let location = delegate?.getDeviceLocation()
        let nearby = delegate?.getNearbies(fromLocation: location)
        map.setCenterCoordinate(location!.coordinate, animated: true)        
        UIApplication.delay(0.15) { () -> () in
            self.resetMapAnnotations(self.map, nearby : nearby!, andRegion: true)
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resetMapAnnotations(map : MKMapView, nearby : [CurrentObject], andRegion isRegionSet : Bool = false) {
        if isRegionSet {
            let minLongitude = nearby.reduce(Double.infinity, combine: { min($0 , $1.lon) })
            let maxLongitude = nearby.reduce(-Double.infinity, combine: { max($0 , $1.lon) })
            let minLatitude = nearby.reduce(Double.infinity, combine: { min($0 , $1.lat) })
            let maxLatitude = nearby.reduce(-Double.infinity, combine: { max($0 , $1.lat) })
            let centerLat = (maxLatitude + minLatitude) / 2
            let centerLon = (maxLongitude + minLongitude) / 2
            let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(centerLat), longitude: CLLocationDegrees(centerLon))
            let deltaLat = abs(maxLatitude - minLatitude) * 1.5
            let deltaLon = abs(maxLongitude - minLongitude) * 1.3
            let span = MKCoordinateSpanMake(CLLocationDegrees(deltaLat), CLLocationDegrees(deltaLon))
            let region = MKCoordinateRegionMake(center, span)
            
            map.setRegion(region, animated: false)
        }        
        map.removeAnnotations(map.annotations)
        map.addAnnotations(nearby)
    }
}

extension MapViewController : MKMapViewDelegate {
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.map.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            // user changed map region
            UIApplication.delay(0.25, closure: { () -> () in
                let location = CLLocation(latitude: self.map.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
                let nearby = self.delegate?.getNearbies(fromLocation: location)
                self.resetMapAnnotations(mapView, nearby: nearby!)
            })
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            // user changed map region
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let c = annotation as? CurrentObject {
            var v : MKAnnotationView? = nil
            if let a = mapView.dequeueReusableAnnotationViewWithIdentifier("Identifier_Map") {
                a.annotation = annotation
                v = a
            } else {
                v = MKAnnotationView(annotation: annotation, reuseIdentifier: "Identifier_Map")
            }
            var image = UIImage(named: "icon-turbine")
            var color = UIColor.flatMidnightBlueColor()
            if let _ = c.lastupdate {
                color = c.units.getColorOfSpeed(c.speedvalue)
                image = UIImage(named: "\(c.directioncode)-white")
            }
            let btn = UIButton(type: .DetailDisclosure)
            btn.addTarget(self, action: "pressedAnnotation:", forControlEvents: .TouchUpInside)
            v?.rightCalloutAccessoryView = btn
            v?.canShowCallout = true
            v?.image = image
            v?.backgroundColor = color.colorWithAlphaComponent(CGFloat(0.75))
            v?.layer.cornerRadius = (v?.frame.size.width)! / 2
            
            return v
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        var i = -1;
        for view in views {
            i++;

            // Check if current annotation is inside visible map rect, else go to next one
            let point:MKMapPoint  =  MKMapPointForCoordinate(view.annotation!.coordinate);
            if (!MKMapRectContainsPoint(self.map.visibleMapRect, point)) {
                continue;
            }
            
            UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                view.transform = CGAffineTransformMakeScale(1.0, 0.6)
                }, completion: {(Bool) in
                    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations:{() in
                        view.transform = CGAffineTransformIdentity
                        }, completion: nil)
            })
        }
    }
    
    func pressedAnnotation(sender: UIButton!) {
        if let c = selectedCurrentObject {
            close(self)
            delegate?.showCurrentObject(c)
        }
        selectedCurrentObject = nil
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let c = view.annotation as? CurrentObject {
            selectedCurrentObject = c
        }
    }
}