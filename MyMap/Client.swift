//
//  Client.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/2/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation


class Client : NSObject {
    
    // MARK: Properties
    
    /* Shared session */
    var session: URLSession
    
    /* Authentication service */
    var authServiceUsed: AuthService?
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    

    
    // MARK: Initializers
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(method: String, baseURLSecure: String, parameters: [String: AnyObject]?, headers: [String:String]?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL and configure the request */
        
        var urlString: String
        if let parameters = parameters {
            urlString = baseURLSecure + method + Client.escapedParameters(parameters: parameters)
        } else {
            urlString = baseURLSecure + method
        }
        
        let url = NSURL(string: urlString)!
      
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            Client.manageErrors(data: data as NSData?, response: response, error: error as NSError?, completionHandler: completionHandler )
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            if let data = data {
                
                var newData: NSData
                let rangeStartByte = 0  // rangeStartByte is equivalent to "currentByte" from question
                let maxSubdataLength = 5
                
                if method.contains("users") {
                    let subdataLength = min(maxSubdataLength, data.count - 5)
                    
                    newData = data.subdata(in: rangeStartByte ..< (rangeStartByte + subdataLength)) as NSData
                    
                } else {
                    newData = data as NSData
                }
                Client.parseJSONWithCompletionHandler(data: newData, completionHandler: completionHandler )
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: POST
    func taskForPOSTMethod(method: String, baseURLSecure: String, headers: [String:String]?, jsonBody: [String:AnyObject]?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        /* 2/3. Build the URL and configure the request */
        let request = NSMutableURLRequest(url: URL(string: baseURLSecure)!)
        request.httpMethod = "POST"

        if let headers = headers {
            for (key, value) in headers {
                request.addValue(key, forHTTPHeaderField: value)
            }
    
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        
        if(!baseURLSecure.isEmpty && baseURLSecure == Client.Constants.ParseBaseURLSecure)
        {
            request.httpBody = try! JSONSerialization.data(withJSONObject: jsonBody, options: .prettyPrinted)
        }else
        {
            request.httpBody = "{\"udacity\": {\"username\": \"\(jsonBody?[Client.JSONBodyKeys.Username] as! String)\", \"password\": \"\(jsonBody?[Client.JSONBodyKeys.Password] as! String)\"}}".data(using: String.Encoding.utf8)
        }
    
        print(request.allHTTPHeaderFields as Any)
        print(NSString(data: request.httpBody!, encoding:String.Encoding.utf8.rawValue)!)
      
        let session = URLSession.shared
 
        //
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
       
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            Client.manageErrors(data: data as NSData?, response: response, error: error as NSError?, completionHandler: completionHandler )
            
            guard (error == nil) else {
                print("Something went wrong with your POST request: \(String(describing: error))")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your status code does not conform to 2xx.")
                return
            }
            
            guard let data = data else {
                print("The request returned no data.")
                return
            }
      
            if((method.contains(Client.Methods.Updatelocation) || method.contains(Client.Methods.AddLocation))
                && statusCode == 200)
            {
                Client.parseJSONWithCompletionHandler( data: newData as! NSData, completionHandler: completionHandler )
                
            }
            else{
                completionHandler(data as AnyObject, nil)
            }
       
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
 
    // MARK: DELETE
      func taskForDELETEMethod(method: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
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
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    
    class func manageErrors(data: NSData?, response: URLResponse?, error: NSError?, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            print("Error: There was an error with your request: \(error)")
            let modifiedError = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: error!.localizedDescription])
            completionHandler(nil, modifiedError)
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 403 {
                    print("Authentication Error: Status code: \(response.statusCode)!")
                    completionHandler(nil, NSError(domain: "Authentication Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Status code: \(response.statusCode)!"]))
                } else {
                    print("Server Error: Your request returned an invalid response! Status code: \(response.statusCode)!")
                    completionHandler(nil, NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response! Status code: \(response.statusCode)!"]))
                }
            } else if let response = response {
                print("Server Error: Your request returned an invalid response! Response: \(response)!")
                completionHandler(nil, NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response! Response: \(response)!"]))
            } else {
                print("Server Error: Your request returned an invalid response!")
                completionHandler(nil, NSError(domain: "Server Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Your request returned an invalid response!"]))
            }
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let _ = data else {
            print("Network Error: No data was returned by the request!")
            completionHandler(nil, NSError(domain: "Network Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request!"]))
            return
        }
    }

    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
     
            let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? [String : Any]
       
            parsedResult = json as AnyObject
            
            let posts = parsedResult["posts"] as? [[String: Any]] ?? []
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
      
    // MARK: Shared Instance
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        
        return Singleton.sharedInstance
    }
}
