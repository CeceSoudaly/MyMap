//
//  MapLocationViewController.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/16/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapLocationViewContoller: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    
    @IBOutlet weak var locationMap: MKMapView!
    
    var locationManager: CLLocationManager!
    
    var currentLocation: CLLocation?
    
    var enteredLocation: String = "Anonymous"
    
    let homeLocation = CLLocation(latitude: 44.806524000000003, longitude: -93.126659000000004)
    let regionRadius: CLLocationDistance = 300
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("enteredLocation>>>", enteredLocation)
//       locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//
//        // Check for Location Services
//
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.requestWhenInUseAuthorization()
//         }
//
//        DispatchQueue.main.async {
//
//            self.locationManager.startUpdatingLocation()
//        }
//        locationMap.delegate = self
//        locationMap.showsUserLocation = true
//        centerMapOnLocation(location: homeLocation)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        var annotations = [MKPointAnnotation]()
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        locationMap.addAnnotations(annotations)
        locationMap.setRegion(coordinateRegion, animated: true)
    }
    
}
