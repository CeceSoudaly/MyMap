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
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var DetailMap: MKMapView!
    
    @IBOutlet weak var urlEntryTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var findLocationButton: UIButton!
    
    @IBOutlet weak var lableText: UILabel!
    
    @IBOutlet var statusLabel: [UILabel]!
    
    var locationManager: CLLocationManager!
    
    var currentLocation: CLLocation?
    
    let regionRadius: CLLocationDistance = 300
    
    var keyboardOnScreen = false
    
    var studentLocation = StudentLocation.sharedInstance
    
    enum viewState {
        case One
        case Two
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewState(viewState: .One)
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
        
//        if locationTextField.text!.isEmpty {
//            //debugTextLabel.text = "Username or Password Empty."
//            
//        } else {
//            setUIEnabled(false)
//            logIntoUdacity()
//        }
    }
    
    @IBAction func beginUrlEditing(_ sender: Any) {
        userDidTapView(self)
        urlEntryTextField.text = ""
    }
    
    func  Cancel()
    {
        print("Cancel out")
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "StudentsTableViewContoller") as! StudentsTableViewContoller
        
        self.navigationController!.pushViewController(editController, animated: true)
        self.tabBarController?.tabBar.isHidden = false
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

    
    @IBAction func geocodeFinder(_ sender: Any) {

        guard let address = locationTextField.text else { return }
        
        print("\(address)")
        print("Get the Geo location",locationTextField.text!)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address,
                    completionHandler: { placemarks, error in
                    self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                centerMapOnLocation(location: location)
            } else {
                Client.showAlert(caller: self, error: error! as NSError)
                print("No Matching Location Found.")
            }
        }
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
        
        //set students information
        //Post the url
        //Set the student's information
        studentLocation.firstName = "Jane2"
        studentLocation.lastName = "Smith2"
        studentLocation.uniqueKey = "DAGjDO9B0Q"
        studentLocation.mapString = "MapTest"
        studentLocation.mediaURL = "https://udacity.com"
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
        
        
        Client.sharedInstance().postStudentLocation(studentLocation: studentLocation) { (success, error) in
            
            if error != nil {
                DispatchQueue.main.async(execute: {
                    Client.showAlert(caller: self, error: error!)
                })
            } else if success {
                print("StudentLocation posted")
                DispatchQueue.main.async() {
//                    self.dismiss(animated: true, completion: nil)
                    
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
