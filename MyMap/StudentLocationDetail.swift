//
//  StudentLocationDetail.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/6/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StudentLocationDetailViewContoller: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var debugLabel: UILabel!
    
   
    @IBOutlet weak var DetailMap: MKMapView!

   var locationManager: CLLocationManager!

   var currentLocation: CLLocation?
  
    var studentLocation = StudentLocation.sharedInstance
    
    enum viewState {
        case One
        case Two
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
       
        setViewState(viewState: .One)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
    }
    
  
    func  Cancel()
    {
        print("Cancel out")
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "StudentsTableViewContoller") as! StudentsTableViewContoller
        
        self.navigationController!.pushViewController(editController, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func geocodeFinder(_ sender: Any) {
//        guard let country = location.text! else { return }
        //        guard let street = streetTextField.text else { return }
        guard let address = location.text else { return }
        
        print("\(address)")
        print("Get the Geo location",location.text!)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString("524 Ct St, Brooklyn, NY 11231",
            completionHandler: { placemarks, error in
            self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
   
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {

        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
                        debugLabel.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
                
                print("Your location: (\(location))")

            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("Your coordinate  : (\(coordinate))")
                debugLabel.text = "\(coordinate.latitude), \(coordinate.longitude)"
                debugLabel.text = "\(coordinate)"
                debugLabel.text = "Matching Location Found"
    
                
                // When the array is complete, we add the annotations to the map.
                //mapLocation.
                 performUIUpdatesOnMain {
                    //Tab view controller
                    let viewControllerB = MapLocationViewContoller()
                    viewControllerB.currentLocation = location

                    self.navigationController?.pushViewController(viewControllerB, animated: true)
                   
                    
//                    let mapDetailController = self.storyboard!.instantiateViewController(withIdentifier: "MapDetail")
//                    
//                   self.navigationController!.pushViewController(mapDetailController, animated: true)
//                    self.tabBarController?.tabBar.isHidden = true
                }
       
                
            } else {
                debugLabel.text = "No Matching Location Found"
                print("No Matching Location Found.")
            }
        }
    }
    
//    func locationManager(locations: [CLLocation]) {
//        defer { currentLocation = locations.last }
//        
//        if currentLocation == nil {
//            // Zoom to user location
//            if let userLocation = locations.last {
//                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
//                locationMap.setRegion(viewRegion, animated: false)
//
//            }
//        }
//    }

    
    func setViewState(viewState: viewState) {
        switch viewState {
        case .One:
        navigationItem.hidesBackButton = true
        let leftItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: Selector("Cancel"))
        navigationItem.rightBarButtonItem = leftItem
        navigationItem.title = "Student's Detail"
        navigationItem.hidesBackButton = true
        DetailMap.delegate = self
        DetailMap.isHidden = true
        
//            fullView.backgroundColor = UIColor(white:0.8, alpha:1.0)    // set bg color to light gray
//            cancelButton.setTitleColor(UIColor(red:0.2, green:0.4, blue:0.6, alpha:1.0), forState: .Normal) // set title color to this bluish tinge
//            topView1.hidden     = false
//            middleView1.hidden  = false
//            bottomView1.hidden  = false
//            mapView.hidden      = true
//            topView2.hidden     = true
//            bottomView2.hidden  = true
//            activityIndicator.hidden = true
              break
        case .Two:
//            fullView.backgroundColor = UIColor(red:0.2, green:0.4, blue:0.6, alpha:1.0) // set bg color to this bluish tinge
//            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal) // set title color to white
//            topView1.hidden     = true
//            middleView1.hidden  = true
//            bottomView1.hidden  = true
//            mapView.hidden      = false
//            topView2.hidden     = false
//            bottomView2.hidden  = false
//            activityIndicator.hidden = true
            break
        }
    }
}
