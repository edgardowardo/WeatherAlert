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
    func getNearbyCurrents() -> [CurrentObject]
    func getCurrentLocation() -> CLLocation
    func showCurrentObject(var current : CurrentObject)
}

class MapViewController: UIViewController {
    
    // MARK: - Properties -
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = delegate?.getCurrentLocation(), nearby = delegate?.getNearbyCurrents() {
            let minLongitude = nearby.reduce(Double.infinity, combine: { min($0 , $1.lon) })
            let maxLongitude = nearby.reduce(-Double.infinity, combine: { max($0 , $1.lon) })
            let minLatitude = nearby.reduce(Double.infinity, combine: { min($0 , $1.lat) })
            let maxLatitude = nearby.reduce(-Double.infinity, combine: { max($0 , $1.lat) })
            let centerLat = (maxLatitude + minLatitude) / 2
            let centerLon = (maxLongitude + minLongitude) / 2
            let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(centerLat), longitude: CLLocationDegrees(centerLon))
            let deltaLat = abs(maxLatitude - minLatitude) * 1.3
            let deltaLon = abs(maxLongitude - minLongitude) * 1.3
            let span = MKCoordinateSpanMake(CLLocationDegrees(deltaLat), CLLocationDegrees(deltaLon))
            let region = MKCoordinateRegionMake(center, span)

            map.setRegion(region, animated: false)
            map.removeAnnotations(map.annotations)
            map.addAnnotations(nearby)
        }
    }
    
    // MARK: - Helper lifecycle -
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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