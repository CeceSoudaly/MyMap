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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButtonPin = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.plain, target: self, action: "pinButtonTouchUp")
        let barButtonRefresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "refreshButtonTouchUp")
        
        self.navigationItem.rightBarButtonItems = [barButtonRefresh, barButtonPin]
        getLocationsOnMap()   // Get locations from Parse and set them on map annotations
        mapView.delegate = self
       
    }
    
    func showAlert(caller: UIViewController, error: NSError) {
        print((error.domain),(error.localizedDescription))
        let alert = UIAlertController(title: error.domain, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
        caller.present(alert, animated: true, completion: nil)
    }
    
    func getLocationsOnMap () {
        
        var annotations = [MKPointAnnotation]()
        
        for location in StudentLocation.sharedInstance.studentArray {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
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
        
        // When the array is complete, we add the annotations to the map.
        mapView.addAnnotations(annotations)
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
    
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //            if control == annotationView.rightCalloutAccessoryView {
    //                let app = UIApplication.sharedApplication
    //                app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //            }
    //        }
    
    func getStudentLocationData(_ completionHandlerForMap: @escaping (_ result: [StudentLocation]?, _ error: NSError?) -> Void) -> URLSessionTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        
        var parsedResult: AnyObject!
        
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            
            let parsedData = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            //BUILD THE ARRAY
            parsedResult = parsedData.value(forKey: "results") as! [[String: AnyObject]] as AnyObject!
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForMap(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            //            guard let data = data else {
            //                sendError("No data was returned by the request!")
            //                return
            //            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            let studentsLocations = StudentLocation.arrayFromResults(results: parsedResult as! [[String : AnyObject]])
            completionHandlerForMap(studentsLocations, nil)
            
            
            
        }
        
        task.resume()
        
        return task
        
        
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

