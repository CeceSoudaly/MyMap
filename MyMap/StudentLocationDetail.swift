//
//  StudentLocationDetail.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/6/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation
import UIKit

class StudentLocationDetailViewContoller: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel",style: .plain, target: self, action: #selector(Cancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Cancel",style: .plain, target: self, action: #selector(Cancel))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
    }
    
    func  Cancel()
    {
        print("Cancel out")
        dismiss(animated: true, completion: nil)
    }
   
}
