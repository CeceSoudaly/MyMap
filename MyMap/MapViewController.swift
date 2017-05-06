//
//  ViewController.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/10/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITabBarItem!
    
    var StudentLocations: [StudentLocation] = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButtonPin = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.plain, target: self, action: "pinButtonTouchUp")
        let barButtonRefresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "refreshButtonTouchUp")
        
        self.navigationItem.rightBarButtonItems = [barButtonRefresh, barButtonPin]
        getLocationsForMap ()   // Get locations from Parse and set them on map annotations
        mapView.delegate = self
       
    }
   
    
    func getLocationsForMap () {
        
        Client.sharedInstance().getStudentLocations(){ (success, error) in
            
            if error != nil {
                DispatchQueue.main.async(execute: {
                    self.showAlert(caller: self, error: error!)
                })
            } else if (success != nil) {
                print("Got student data")
                DispatchQueue.main.async() {
                    
                    self.setLocationsOnMap()
                }
            } else {
                DispatchQueue.main.async(execute: {
                    let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get student data."])
                    self.showAlert(caller: self, error: error)
                })
            }
        }
    }
    
    func setLocationsOnMap () {
        
        var annotations = [MKPointAnnotation]()
        
        for location in StudentLocation.sharedInstance.studentArray{
           // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            if(location.latitude != nil)
            {
                let lat = CLLocationDegrees(location.latitude! as Float)
                let long = CLLocationDegrees(location.longitude! as Float)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let first = location.firstName! as String
                let last = location.lastName! as String
                let mediaURL = location.mediaURL! as String
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
         
         
        }
        
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
    
    }
 
  
    func showAlert(caller: UIViewController, error: NSError) {
        print((error.domain),(error.localizedDescription))
        let alert = UIAlertController(title: error.domain, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
        caller.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    
   
    
    
    //    /* Helper: Given raw JSON, return a usable Foundation object */
    //    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
    //
    //        var parsedResult: AnyObject!
    //        do {
    //            parsedResult = JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject!
    //        } catch {
    //            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
    //            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
    //        }
    //        
    //        completionHandler(parsedResult, nil)
    //    }
    

}

