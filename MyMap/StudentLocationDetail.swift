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
    
    var appDelegate: AppDelegate!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var DetailMap: MKMapView!
    
    @IBOutlet weak var urlEntryTextField: UITextField!
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var middleView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
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
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
//        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
//        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
//        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
//        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
        setViewState(viewState: .One)
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
    
    @IBAction func geocodeFinder(_ sender: Any) {
        //        guard let country = location.text! else { return }
        //        guard let street = streetTextField.text else { return }
        guard let address = locationTextField.text else { return }
        
        print("\(address)")
        print("Get the Geo location",locationTextField.text!)
        
        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString("524 Ct St, Brooklyn, NY 11231",
//                                      completionHandler: { placemarks, error in
//                                        self.processResponse(withPlacemarks: placemarks, error: error)
        geoCoder.geocodeAddressString(address,
                    completionHandler: { placemarks, error in
                    self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
//            debugLabel.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
                
                print("Your location: (\(location))")
                
            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("Your coordinate  : (\(coordinate))")
//                debugLabel.text = "\(coordinate.latitude), \(coordinate.longitude)"
//                debugLabel.text = "\(coordinate)"
//                debugLabel.text = "Matching Location Found"
                
                
                // When the array is complete, we add the annotations to the map.
                //mapLocation.
                centerMapOnLocation(location: location)
                setViewState(viewState: .Two)
       
                
            } else {
//                debugLabel.text = "No Matching Location Found"
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
        
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        DetailMap.addAnnotations(annotations)
        DetailMap.setRegion(coordinateRegion, animated: true)
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
            findLocationButton.isHidden = false
           
            
            //            fullView.backgroundColor = UIColor(white:0.8, alpha:1.0)    // set bg color to light gray
            //            cancelButton.setTitleColor(UIColor(red:0.2, green:0.4, blue:0.6, alpha:1.0), forState: .Normal) // set
            //            activityIndicator.hidden = true
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
            topView.isHidden = true
            
            
            //            fullView.backgroundColor = UIColor(red:0.2, green:0.4, blue:0.6, alpha:1.0) // set bg color to this bluish tinge
            //            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal) // set title color to white
            //            activityIndicator.hidden = true
            
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
