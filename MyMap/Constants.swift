//
//  Constants.swift
//  MyMap
//
//  Created by Cece Soudaly on 4/12/17.
//  Copyright © 2017 CeceMobile. All rights reserved.
//

import Foundation


struct Constants {
    
    // MARK: TMDB
    struct TMDB {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/3"
        static let username = "ccsoudal@yahoo.com"
        static let password = "Apple.2017"
    }
    
    // MARK: TMDB Parameter Keys
    struct TMDBParameterKeys {
        static let ApiKey = "api_key"
        static let RequestToken = "request_token"
        static let SessionID = "session"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: TMDB Parameter Values
    struct TMDBParameterValues {
        static let ApiKey = "28c7f7d8905b411ff79583ff2ce2f4e8"
    }
    
    // MARK: TMDB Response Keys
    struct TMDBResponseKeys {
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
}
