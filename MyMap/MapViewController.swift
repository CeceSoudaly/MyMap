//
//  ViewController.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/10/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITabBarItem!
    var activityIndicator = UIActivityIndicatorView()
    var StudentLocations: [StudentLocation] = [StudentLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "icon_pin")?.withRenderingMode(.alwaysOriginal)
        
        
        let Nam1BarBtnVar = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        let Nam2BarBtnVar = UIBarButtonItem(image: image, style: .plain,target: self, action: #selector(addLocation))
        
        self.navigationItem.setRightBarButtonItems([Nam1BarBtnVar, Nam2BarBtnVar], animated: true)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"LogOut",style: .plain, target: self, action: #selector(logOut))

        getLocationsForMap ()   // Get locations from Parse and set them on map annotations
        mapView.delegate = self
    }
    func editLocation() {
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "StudentsTableViewContoller") as! StudentsTableViewContoller
        
        self.navigationController!.pushViewController(editController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func addLocation(){
        
        print("addLocation")
        
        Client.sharedInstance().queryStudentName{ (success, error) in
            
            if error != nil {
                DispatchQueue.main.async(execute: {
                    Client.showAlert(caller: self, error: error!)
                    
                })
            } else if success {
                print("Session found a Student?")
                DispatchQueue.main.async {
                    //self.dismiss(animated: true, completion: nil)
                    //look up students
                    self.getSingleStudentLocation()
                }
            } else {
                DispatchQueue.main.async(execute: {
                    let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find a student"])
                    Client.showAlert(caller: self, error: error)
                    
                })
            }
        }
    }
    
    func getSingleStudentLocation(){
        
        var first = ""
        var last  = ""
        var mediaURL  = ""
        
        for location in StudentLocation.sharedInstance.studentArray{
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            if(location.latitude != nil)
            {
                
                if(!(location.firstName?.isEmpty)! && location.firstName != nil ){
                    first = location.firstName! as String
                }
                
                if(!(location.lastName?.isEmpty)! && location.lastName != nil ){
                    last = location.lastName! as String
                }
                
                if( location.mediaURL != nil && !(location.mediaURL?.isEmpty)!){
                    mediaURL = location.mediaURL! as String
                }
                
            }
            
            if(!first.isEmpty && !last.isEmpty)
            {
                let refreshAlert = UIAlertController(title: nil, message: "You already posted a student location. Do you want to overwrite your current location?", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
                    print("Handle Ok logic here")
                    performUIUpdatesOnMain {
                        //Tab view controller
                        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "LocationDetailsController")
                        self.navigationController!.pushViewController(detailController, animated: true)
                        self.tabBarController?.tabBar.isHidden = true
                    }
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                // show the alert
            }
        }
        
    }
    func logOut(){
        print("logOut")
        // Check which auth service was used to log in
        
        if (Client.sharedInstance().authServiceUsed == Client.AuthService.Facebook){
            FBSDKLoginManager().logOut()
            print("Facebook logout")
            
            DispatchQueue.main.async {
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }

        } else {    // if Udacity was used to log in

            Client.sharedInstance().deleteSession() { (success, error) in

            if error != nil {
                DispatchQueue.main.async(execute: {
                    Client.showAlert(caller: self, error: error!)
                    
                })
            } else if success {
                print("Session Deleted")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async(execute: {
                    let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not delete/logout session"])
                    Client.showAlert(caller: self, error: error)
                    
                })
            }
            }
        }
        
    }
    
    func refresh()
    {
        print("refresh")
        let spinner = startActivityIndicatorView()
       
            for annotation : MKAnnotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
            
            self.getLocationsForMap()
     
        stopActivityIndicatorView(activityView: spinner)
    }
    
    func startActivityIndicatorView() -> UIActivityIndicatorView {
        let x = (self.view.frame.width / 2)
        let y = (self.view.frame.height / 2) - (self.navigationController?.navigationBar.frame.height)!
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.frame = CGRect(x: 200, y: 120, width: 200, height: 200)
        activityView.center = CGPoint(x: x, y: y)
        activityView.color = .blue
        activityView.startAnimating()
        self.view.addSubview(activityView)
        
        return activityView
    }
    
    func stopActivityIndicatorView(activityView: UIActivityIndicatorView) {
        DispatchQueue.main.async() {
            activityView.removeFromSuperview()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mapView.frame = self.view.bounds;
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
                
                var first = "[NO_FIRSTNAME]"
                var last  = "[NO_LASTNAME]"
                var mediaURL  = "[NO_URL]"
                 
                
                if(!(location.firstName?.isEmpty)! && location.firstName != nil ){
                     first = location.firstName! as String
                }
                
                if(!(location.lastName?.isEmpty)! && location.lastName != nil ){
                     last = location.lastName! as String
                }
                
                if( location.mediaURL != nil && !(location.mediaURL?.isEmpty)!){
                     mediaURL = location.mediaURL! as String
                }

                
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

