//
//  Convienence.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/2/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Client (Convenient Resource Methods)

extension Client {
    
     // MARK: PARSE - GETting StudentLocations
    
    func getStudentLocations(completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters: [String: AnyObject] = [
            Client.ParameterKeys.Limit: Int(100) as AnyObject,
            Client.ParameterKeys.Order: "-updatedAt" as AnyObject
        ]
        let method : String = Methods.ParseGetStudentLocations
        let headers : [String:String] = [
            Client.HeaderKeys.ParseAppID: Client.Constants.AppID,
            Client.HeaderKeys.ParseRESTAPIKey: Client.Constants.RESTApiKey
        ]
        
        /* 2. Make the request */
        taskForGETMethod(method: method, baseURLSecure: Client.Constants.ParseBaseURLSecure, parameters: parameters, headers: headers) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(false, error)
            } else {
                
                if let results = JSONResult?["results"] as? [[String : AnyObject]] {
                    
                    let studentLocations = StudentLocation.sharedInstance
                    studentLocations.studentArray  = StudentLocation.arrayFromResults(results: results)
                    studentLocations.studentArray.filter{ $0 != nil }.map{ $0 }

                    completionHandler(true, nil)
                    
                } else {
                    completionHandler(false, NSError(domain: "Client Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations data."]))
                }
            }
        }
    }
  
    func queryStudentName(completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let method: String
        if let uniqueKey = StudentLocation.sharedInstance.uniqueKey {
            method = substituteKeyInMethod(Methods.UdacityUserData, key: URLKeys.UserID, value: uniqueKey)!
        } else {
            let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot post when logged in with Facebook credentials. Please log in with Udacity credentials."])
            completionHandler(false, error)
            return
        }
        
        /* 2. Make the request */
        taskForGETMethod(method: method, baseURLSecure: Client.Constants.UdacityBaseURLSecure, parameters: nil, headers: nil) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(false, error)
            } else {
                
                if let result = JSONResult?["user"] as! [String : AnyObject]? {    // If result, store first and last name in sharedinstance object
                    
                    let studentLocation = StudentLocation.sharedInstance
                    if let firstname = result["first_name"] {
                        print(firstname)
                        studentLocation.firstName = firstname as? String
                    }
                    if let lastname = result["last_name"] {
                        print(lastname)
                        studentLocation.lastName = lastname as? String
                    }
                    if (studentLocation.firstName != nil) && (studentLocation.lastName != nil) {
                        completionHandler(true, nil)
                        print("In queryStudentName -> \(studentLocation.firstName!) \(studentLocation.lastName!)")    // debug
                    } else {
                        completionHandler(false, NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get user's name from server."]))
                    }
                    
                } else {
                    completionHandler(false, NSError(domain: "Client Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse queryStudentName data."]))
                }
            }
        }
    }
    
    func deleteSession(completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                
                completionHandler(false, NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not delete the session"]))
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            completionHandler(true, nil)
        }
        
        task.resume()
    }

    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }

}
