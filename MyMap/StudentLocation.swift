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
        
        objectId = dictionary[Client.JSONResponseKeys.objectId] as? String
        uniqueKey = dictionary[Client.JSONResponseKeys.uniqueKey] as? String
        firstName = dictionary[Client.JSONResponseKeys.firstName] as? String
        lastName = dictionary[Client.JSONResponseKeys.lastName] as? String
        mapString = dictionary[Client.JSONResponseKeys.mapString] as? String
        mediaURL = dictionary[Client.JSONResponseKeys.mediaURL] as? String
        longitude = dictionary[Client.JSONResponseKeys.longitude] as? Float
        latitude = dictionary[Client.JSONResponseKeys.latitude] as? Float
        createdAt = dictionary[Client.JSONResponseKeys.createdAt] as? String
        updatedAt = dictionary[Client.JSONResponseKeys.updatedAt] as? String
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
