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
        
        let logo = UIImage(named: "icon_mapview-deselected")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        navigationItem.rightBarButtonItem =   UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(addLocation))
        
        navigationItem.leftBarButtonItem =   UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addLocation))
        
       // self.tabBarController?.tabBar.isHidden = false
         tableView.delegate = self
        
    }
    
    func editLocation() {
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "StudentsTableViewContoller") as! StudentsTableViewContoller
        
        self.navigationController!.pushViewController(editController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: Table View Data Source
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StudentLocations = StudentLocation.sharedInstance.studentArray
        tableView.reloadData()
//        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func addLocation(){
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return StudentLocations.count
    }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
       /* Get cell type */
       let studentLocation = StudentLocation.sharedInstance.studentArray[indexPath.row]
       /* Set cell defaults */
       let first = studentLocation.firstName! as String
       let last = studentLocation.lastName! as String
       let mediaURL = studentLocation.mediaURL! as String
       cell.imageView!.image = UIImage(named: "pin")
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
