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
  
    func queryStudentName(studentUdacityKey: String,completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void {
        
        let parameters: [String: AnyObject] = [
//            Client.ParameterKeys.Where: Client.Methods.UdacityUniqueKey  as AnyObjec
              Client.ParameterKeys.Where: "{\"uniqueKey\":\"\(studentUdacityKey)\"}" as AnyObject
         ]
        
        let method : String = ""
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
                    
                    let studentLocation = StudentLocation.sharedInstance
                    studentLocation.studentArray  = StudentLocation.arrayFromResults(results: results)
                    studentLocation.studentArray.filter{ $0 != nil }.map{ $0 }
                    completionHandler(true, nil)
                    
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
   
   /* Login into Udacity Parse
     
     */
    func postSession(username: String, password: String,completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let method : String = Client.Methods.Updatelocation
       
        let jsonBody : [String:String] = [
                Client.JSONBodyKeys.Username: "\(username)",
                Client.JSONBodyKeys.Password: "\(password)"
        ]


        /*2. Make the request*/
        taskForPOSTMethod(method: method, baseURLSecure: Client.Constants.UdacityBaseURLSecure, headers: nil, jsonBody: jsonBody as [String : AnyObject]?) { JSONResult, error in

            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print("Phooey!")
                completionHandler(false, error)
            } else {
               
                if let error = error {
                    completionHandler(false, error)
                } else {
                
                    if let jsonResult = JSONResult as? Dictionary<String, AnyObject> {
                        let account = jsonResult["account"]
                        print("account >>> ", account)
                        var keyAccount = account as! Dictionary<String, AnyObject>
                        let key = keyAccount ["key"]
                         print("key >>> ", key)
                        
                        let studentLocations = StudentLocation.sharedInstance
                        studentLocations.uniqueKey = key as! String

                        completionHandler(true, nil)
                    }
                    else
                    {
                          completionHandler(false, NSError(domain: "Client Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse queryStudentName data."]))
                    }
               }

            }
        }
    }
    
    
    func postStudentLocation(studentLocation: StudentLocation, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
       // let method : String = Methods.ParsePostStudentLocation
        let method : String = Client.Methods.AddLocation
        let headers : [String:String] = [
            Client.Constants.AppID: Client.HeaderKeys.ParseAppID,
            Client.Constants.RESTApiKey: Client.HeaderKeys.ParseRESTAPIKey,
            "application/json": "Content-Type"
        ]
        
        let jsonBody : [String:AnyObject] = [
        Client.JSONResponseKeys.uniqueKey: "\(studentLocation.uniqueKey!)" as AnyObject,
        Client.JSONResponseKeys.firstName: "\(studentLocation.firstName!)" as AnyObject,
        Client.JSONResponseKeys.lastName: "\(studentLocation.lastName!)" as AnyObject,
        Client.JSONResponseKeys.mapString: "\(studentLocation.mapString!)" as AnyObject,
        Client.JSONResponseKeys.mediaURL: "\(studentLocation.mediaURL!)" as AnyObject,
        Client.JSONResponseKeys.latitude:   (studentLocation.latitude! as AnyObject),
        Client.JSONResponseKeys.longitude:  (studentLocation.longitude! as AnyObject)
        ]
        
        /* 2. Make the request */
        taskForPOSTMethod(method: method, baseURLSecure: Client.Constants.ParseBaseURLSecure, headers: headers, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print("Phooey!")
                completionHandler(false, error)
            } else {
                if let _ = JSONResult {
                    completionHandler(true, nil)
                } else {
                    completionHandler(false, NSError(domain: "Client Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocation data."]))
                }
            }
        }
    }
        
    class func showAlert(caller: UIViewController, error: NSError) {
        print((error.domain),(error.localizedDescription))
        let alert = UIAlertController(title: error.domain, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
        caller.present(alert, animated: true, completion: nil)
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
