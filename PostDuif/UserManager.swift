//
//  UserManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class UserManager{
    
    class func loginUser(apiEndPoint: String, completionHandler: (response: Token) -> ()) {
        
        // Making GET request to the URL
        request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            if (json != nil) {
                
                var token = Token()
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                
                if let code = jsonObj["code"].string{
                    token.setReturnCode(code)
                    
                    if let jsonToken = jsonObj["token"].string{
                        token.setToken(jsonToken)
                    }
                    
                    if let status = jsonObj["status"].string{
                        token.setStatus(status)
                    }
                    
                    if let message = jsonObj["message"].string{
                        token.setMessage(message)
                    }
                    
                    // Make new JSON array
                    if let dataArray = jsonObj["data"].array {
                        for r in dataArray{
                            token.setExpireTokenDate(r["expireTokenDate"].stringValue)
                            token.setRefreshToken(r["refreshToken"].stringValue)
                        }
                    }
                    
                    println(json)
                    
                    completionHandler(response: token)
                }
            }
        }
    }
}
