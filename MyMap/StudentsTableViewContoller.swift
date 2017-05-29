//
//  StudentLocationTableView.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/6/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit


class StudentsTableViewContoller: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var StudentLocations: [StudentLocation] = [StudentLocation]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "icon_pin")?.withRenderingMode(.alwaysOriginal)
       
       
        let Nam1BarBtnVar = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        let Nam2BarBtnVar = UIBarButtonItem(image: image, style: .plain,target: self, action: #selector(addLocation))
        
        self.navigationItem.setRightBarButtonItems([Nam1BarBtnVar, Nam2BarBtnVar], animated: true)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"LogOut",style: .plain, target: self, action: #selector(logOut))
        tableView.delegate = self
        
    }
    
    // MARK: Table View Data Source
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StudentLocations = StudentLocation.sharedInstance.studentArray
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func editLocation() {
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "StudentsTableViewContoller") as! StudentsTableViewContoller
        
        self.navigationController!.pushViewController(editController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func addLocation(){
        
        print("addLocation")
        //LocationDetails
        
//        let alert = UIAlertController(title: "UIAlertController", message: "You are about do you want to add more location?", preferredStyle: UIAlertControllerStyle.alert)
//
//        // add the actions (buttons)
//        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
//
//        // show the alert
//        self.present(alert, animated: true, completion: nil)

        performUIUpdatesOnMain {
            //Tab view controller
            let detailController = self.storyboard!.instantiateViewController(withIdentifier: "LocationDetailsController")
            self.navigationController!.pushViewController(detailController, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func logOut(){
         print("logOut")
        // Check which auth service was used to log in
        
//        if Client.sharedInstance().authServiceUsed == Client.Constants.AuthService.Facebook {
//            
//            //FBSDKLoginManager().logOut()
//            print("Facebook logout")
//           // dismissViewControllerAnimated(true, completion: nil)
//            
//        } else {    // if Udacity was used to log in
        
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
    
    func refresh()
    {
        print("refresh")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return StudentLocations.count
    }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
       /* Get cell type */
       let studentLocation = StudentLocation.sharedInstance.studentArray[indexPath.row]
       /* Set cell defaults */
        var first = "[NO_FIRSTNAME11]"
        var last  = "[NO_LASTNAME22]"
        var mediaURL  = "[NO_URL33]"
        
        if(studentLocation.firstName != nil){
           first = studentLocation.firstName! as String
        }
        
        if(studentLocation.firstName != nil && studentLocation.lastName != nil){
            last = studentLocation.lastName! as String
        }
        
        if(studentLocation.firstName != nil && studentLocation.lastName != nil){
            mediaURL = studentLocation.mediaURL! as String
        }

        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel!.text = "\(first) \(last)"
        cell.detailTextLabel!.text = mediaURL
        cell.imageView!.contentMode = UIViewContentMode.scaleAspectFit
       return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // Open mediaURL
        let app = UIApplication.shared
        if let toOpen = StudentLocation.sharedInstance.studentArray[indexPath.row].mediaURL {
            app.openURL(NSURL(string: toOpen)! as URL)
        }
    }

    
}
