//
//  UserManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class UserManager{
    
    class func loginUser(apiEndPoint: String, completionHandler: (response: String) -> ()) {
        
        // Making GET request to the URL
        request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            if (json != nil) {
                
                println(json)
//                // Making the JSON object from the JSON
//                var jsonObj = JSON(json!)
//            
//            if let loginCode = jsonObj["code"].string{
//                
//                completionHandler(response: loginCode)
//            }
            }
        }
    }
}
