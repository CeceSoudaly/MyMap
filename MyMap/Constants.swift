//
//  Constants.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/12/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//


import UIKit

 extension Client {
    
    // MARK: OTM
    struct OTM{
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/3"
        static let username = "youremail"
        static let password = "yourpassword"
    }
    
    // MARK: OTM Parameter Keys
    struct OTMParameterKeys {
        static let ApiKey = "api_key"
        static let RequestToken = "request_token"
        static let SessionID = "session"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: OTM Parameter Values
    struct OTMParameterValues {
        static let ApiKey = "28c7f7d8905b411ff79583ff2ce2f4e8"
    }
    
    // MARK: OTM Response Keys
    struct OTMResponseKeys {
        static let Title = "title"
        static let ID = "id"
        static let PosterPath = "poster_path"
        static let StatusCode = "status_code"
        static let StatusMessage = "status_message"
        static let SessionID = "session"
        static let Account = "account"
        static let RequestToken = "request_token"
        static let Success = "success"
        static let UserID = "id"
        static let Results = "results"
    }
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }

    // Authentication services
    enum AuthService {
        case Udacity
        case Facebook
    }
    
    // MARK: Constants
    struct Constants {
        
        // MARK: Parse Authorization
        static let AppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        //
        
        // MARK: Facebook Authorization
        static let FBAppID : String = "365362206864879"
        static let FBSuffix : String = "onthemap"
        
        // MARK: URLs
        static let UdacityBaseURLSecure : String = "https://www.udacity.com/api/session"
        static let ParseBaseURLSecure : String = "https://parse.udacity.com/parse/classes/StudentLocation"
    }
    
    // MARK: Methods
    struct Methods {
        // MARK: Udacity
        static let UdacityUserData = "users/{id}"
        static let UdacityPostSession = "session"
        static let UdacityDeleteSession = "session"
        
        // MARK: Parse
        static let ParseGetStudentLocations = ""
        static let ParsePostStudentLocation = ""
        
    }
    
    
    
    // MARK: URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        
        static let UserID = "id"
        static let Limit = "limit"
        static let Skip = "skip"
        static let Where = "where"
        static let Order = "order"
        
    }
    
    struct HeaderKeys {
        
        static let ParseAppID = "X-Parse-Application-Id"
        static let ParseRESTAPIKey = "X-Parse-REST-API-Key"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: StudentLocation
        static let createdAt = "createdAt"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
        
    }

}
