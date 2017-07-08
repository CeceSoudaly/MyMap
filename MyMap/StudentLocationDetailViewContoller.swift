//
//  StudentLocationDetailViewContoller.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/6/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class StudentLocationDetailViewContoller: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var DetailMap: MKMapView!
    
    @IBOutlet weak var urlEntryTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    @IBOutlet weak var lableText: UILabel!
    
    @IBOutlet var statusLabel: [UILabel]!
    
    var studentLocation = StudentLocation.sharedInstance
    
    var acitivityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var locationManager: CLLocationManager!
    
    var currentLocation: CLLocation?
    
    let regionRadius: CLLocationDistance = 300
    
    var keyboardOnScreen = false
    var first = "[NO_FIRSTNAME]"
    var last  = "[NO_LASTNAME]"
    var mediaURL  = "[NO_URL]"
    var uniqueKey = ""

    
    enum viewState {
        case One
        case Two
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewState(viewState: .One)

        let studentLocations = StudentLocation.sharedInstance
       
        if(studentLocations.uniqueKey != nil )
        {
            uniqueKey = studentLocations.uniqueKey!
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.DetailMap.frame = self.view.bounds;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func beginEditing(_ sender: Any) {
        
        userDidTapView(self)
        locationTextField.text = ""
        
    }
    
    @IBAction func beginUrlEditing(_ sender: Any) {
        userDidTapView(self)
        urlEntryTextField.text = ""
    }
    
    func  Cancel()
    {
        print("Cancel out")
        self.dismiss(animated: false, completion: nil)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func addLocation(){
        
         print(" get student name >>>>> ", uniqueKey )
        Client.sharedInstance().queryStudentName(studentUdacityKey: uniqueKey){ (success, error) in
            
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
        
        for location in StudentLocation.sharedInstance.studentArray{

            if(location.latitude != nil)
            {
                
                if(!(location.firstName?.isEmpty)! && location.firstName != nil){
                    first = location.firstName! as String
                }
                
                if(!(location.lastName?.isEmpty)! && location.lastName != nil ){
                    last = location.lastName! as String
                }
                
                if( location.mediaURL != nil && !(location.mediaURL?.isEmpty)!){
                    mediaURL = location.mediaURL! as String
                }
                if( location.uniqueKey != nil && !(location.uniqueKey?.isEmpty)!){
                    uniqueKey = location.uniqueKey! as String

                }
            }
        }
        
    }

    
    @IBAction func geocodeFinder(_ sender: Any) {

        guard let address = locationTextField.text else { return }
        
        print("\(address)")
        print("Get the Geo location",locationTextField.text!)
        
        acitivityIndicator.center = self.view.center
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(acitivityIndicator)
        acitivityIndicator.startAnimating()
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address,
                    completionHandler: { placemarks, error in
                    self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
             Client.showAlert(caller: self, error: error as NSError)
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                centerMapOnLocation(location: location)
            } else {
                print("No Matching Location Found.")
                Client.showAlert(caller: self, error: error! as NSError)
            }
        }
        
        acitivityIndicator.stopAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()

    }
    
    func locationManager(locations: [CLLocation]) {
        defer { currentLocation = locations.last }

        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                DetailMap.setRegion(viewRegion, animated: false)

            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        var annotations = [MKPointAnnotation]()
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
         self.getSingleStudentLocation()
        //set students information
        //Post the url
        //Set the student's information
        studentLocation.firstName = first
        studentLocation.lastName = last
        studentLocation.uniqueKey = uniqueKey
        studentLocation.mapString = "OnTheMapTest"
        studentLocation.mediaURL = urlEntryTextField.text!
        let latitude = (Float)(location.coordinate.latitude)
        studentLocation.latitude = latitude
        var longitude = (Float)(location.coordinate.longitude)
        studentLocation.longitude = longitude
        
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        DetailMap.addAnnotations(annotations)
        DetailMap.setRegion(coordinateRegion, animated: true)
        
        setViewState(viewState: .Two)
    }
    
    @IBAction func submitLocalnUrl(_ sender: Any) {
        
        
        let StringA = "https://"
        let StringB = urlEntryTextField.text!
        let ResultString = "\(StringA)\(StringB)"
        studentLocation.mediaURL = ResultString
    
        Client.sharedInstance().postStudentLocation(studentLocation: studentLocation) { (success, error) in
            
            if error != nil {
                DispatchQueue.main.async(execute: {
                    Client.showAlert(caller: self, error: error!)
                })
            } else if success {
                print("StudentLocation posted")
                DispatchQueue.main.async() {
                    
                    performUIUpdatesOnMain {
                         //Tab view controller
                        let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! UITabBarController
                        self.present(controller, animated: true, completion: nil)
                    }
                    
                }
            } else {
                DispatchQueue.main.async(execute: {
                    let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not post StudentLocation."])
                    Client.showAlert(caller: self, error: error)
                })
            }
        }
    }
    
    
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
            submitButton.isHidden = true
            urlEntryTextField.isHidden = true
            locationTextField.isHidden = false
            findLocationButton.isHidden = false
       
            break
        case .Two:
            
            navigationItem.hidesBackButton = true
            let leftItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: Selector("Cancel"))
            navigationItem.rightBarButtonItem = leftItem
            navigationItem.title = "Student's Detail"
            navigationItem.hidesBackButton = true
            DetailMap.delegate = self
            DetailMap.isHidden = false
            submitButton.isHidden = false
            urlEntryTextField.isHidden = false
            locationTextField.isHidden = true
            findLocationButton.isHidden = true
            lableText.isHidden = true
            
            break
        }
    }
    
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(urlEntryTextField)
        resignIfFirstResponder(locationTextField)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            //udacityImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
           // udacityImageView.isHidden = false
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
  
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

}
