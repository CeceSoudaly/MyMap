//
//  GCDBlackBox.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/13/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
