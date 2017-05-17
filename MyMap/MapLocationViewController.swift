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
    
    let homeLocation = CLLocation(latitude: 44.806524000000003, longitude: -93.126659000000004)
    let regionRadius: CLLocationDistance = 500
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMap.delegate = self
        locationMap.showsUserLocation = true
        centerMapOnLocation(location: homeLocation)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        locationMap.setRegion(coordinateRegion, animated: true)
    }
    
}
