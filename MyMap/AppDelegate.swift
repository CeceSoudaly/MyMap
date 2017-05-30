//
//  AppDelegate.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/10/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties
    
    var window: UIWindow?
    
    var sharedSession = URLSession.shared
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // configuration for TheMovieDB, we'll take care of this for you =)...
    var config = Config()
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // if necessary, update the configuration...
        config.updateIfDaysSinceUpdateExceeds(7)
        
        return true
    }
    
    func resetAppToFirstController() {
        self.window?.rootViewController = LoginViewController(nibName: nil, bundle: nil)
        
    }
}

// MARK: Create URL from Parameters

extension AppDelegate {
    
    func OTMURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Client.OTM.ApiScheme
        components.host = Client.OTM.ApiHost
        components.path = Client.OTM.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

}

