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
//        navigationItem.rightBarButtonItem =   UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(editMeme))
//        self.tabBarController?.tabBar.isHidden = false
    }
    
    func editLocation() {
        let editController = self.storyboard!.instantiateViewController(withIdentifier: "StudentsTableViewContoller") as! StudentsTableViewContoller
        
        self.navigationController!.pushViewController(editController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: Table View Data Source
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //get the save Memes
        
//        let object = UIApplication.shared.delegate
//        let appDelegate = object as! AppDelegate
//
        StudentLocations = StudentLocation.sharedInstance.studentArray
        print("StudentLocations >>>>>>",StudentLocations)
        
        tableView.reloadData()
//        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        cell.textLabel!.text = "\(first) \(last)"
        cell.imageView!.image = UIImage(named: "pin")
       // cell.detailTextLabel!.text = mediaURL
       cell.imageView!.contentMode = UIViewContentMode.scaleAspectFit
       return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        
////        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
////        detailController.meme = self.allMemes[(indexPath as NSIndexPath).row]
////        self.navigationController!.pushViewController(detailController, animated: true)
   }

    
}
