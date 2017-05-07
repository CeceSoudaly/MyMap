//
//  StudentLocationTableView.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/6/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit


class StudentsLocationTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
//        
//        let meme = self.allMemes[(indexPath as NSIndexPath).row]
//        
//        // textfield1.text! + textfield2.text!
//        let first = meme.topTextField!+"..." + meme.bottomTextField!
//        
//        
//        // Set the name and image
//        cell.textLabel?.text = first
//        cell.imageView?.image =  meme.memedImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
//        detailController.meme = self.allMemes[(indexPath as NSIndexPath).row]
//        self.navigationController!.pushViewController(detailController, animated: true)
    }

    
}
