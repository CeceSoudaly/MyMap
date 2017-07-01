//
//  StudentLocation.swift
//  MyMap
//
//  Created by Cece Soudaly on 5/2/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation


class StudentLocation: NSObject {
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Float?
    var longitude: Float?
    var createdAt: String?
    var updatedAt: String?
    
    static let sharedInstance = StudentLocation()
    
    var studentArray = [StudentLocation]()
    
    // MARK: Initializers
    
    // Construct a StudentLocation from a dictionary
    init(dictionary: [String : AnyObject]) {
     
        if let  objectId = dictionary[Client.JSONResponseKeys.objectId] as? String {
            self.objectId = objectId
        } else {
            self.objectId = ""
        }
        
        if let uniqueKey = dictionary[Client.JSONResponseKeys.uniqueKey] as? String {
            self.uniqueKey = uniqueKey
        }else {
            self.uniqueKey = ""
        }
        
        if let firstName = dictionary[Client.JSONResponseKeys.firstName] as? String {
            self.firstName = firstName
        }else {
            self.firstName = ""
        }
        
        if let lastName = dictionary[Client.JSONResponseKeys.lastName] as? String {
            self.lastName = lastName
        }else {
            self.lastName = ""
        }
        
        if let mapString = dictionary[Client.JSONResponseKeys.mapString] as? String {
            self.mapString = mapString
        }else {
            self.mapString = ""
        }
        
        if let mediaURL = dictionary[Client.JSONResponseKeys.mediaURL] as? String {
            self.mediaURL = mediaURL
        }else {
            self.mediaURL = ""
        }
        
        if let longitude = dictionary[Client.JSONResponseKeys.longitude] as? Float {
            self.longitude = longitude
        } else {
            self.longitude = 0.0
        }
        
        if let latitude = dictionary[Client.JSONResponseKeys.latitude] as? Float {
            self.latitude = latitude
        } else {
            self.latitude = 0.0
        }
        
        if let createdAt = dictionary[Client.JSONResponseKeys.createdAt] as? String {
            self.createdAt = createdAt
        }else {
            self.createdAt = ""
        }
        
        if let updatedAt = dictionary[Client.JSONResponseKeys.updatedAt] as? String {
            self.updatedAt = createdAt
        }else {
            self.updatedAt = ""
        }
    }
    
    override init() {
        objectId = nil
        uniqueKey = nil
        firstName = nil
        lastName = nil
        mapString = nil
        mediaURL = nil
        longitude = nil
        latitude = nil
        createdAt = nil
        updatedAt = nil
    }
    
    // Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects
    static func arrayFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        //clean out any old cache
        studentLocations.removeAll()
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
}
