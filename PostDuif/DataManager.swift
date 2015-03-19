//
//  DataManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class DataManager{
    
    
    class func getMessages(apiEndPoint: String, completionHandler: (response: [Message]) -> ()) {
        
        // Making GET request to the URL
        request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            
            // Making sure if the JSON is not empty
            if (json != nil) {
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                
                
                
                // Make new JSON array
                if let appArray = jsonObj["feed"]["entry"].array {
                    
                    var messageArray = [Message]()
                    
                    // Check for every app in the array
                    for appDict in appArray {
      
                        // Making new Object for putting in the array
                        var newMessage = Message()
                        
                        // Set name inside the object
                        var appName: String = appDict["subject"].stringValue
                        newMessage.setName(appName)
                        
                        // Set the website for the object
                        var appURL: String = appDict["message"].stringValue
                        newMessage.setWebsite(appURL)
                        
                        // Append the app names
                        messageArray.append(newMessage)
                        
                    }
                    
                    // Give the array back to the main Thread
                    completionHandler(response: messageArray)
                    
                    /* Code snippet for getting single item out of JSON array
                    if let appName = jsonObj["feed"]["entry"][1]["im:name"]["label"].string{
                    let test1 = Test(age: 9, name: appName)
                    //self.tableView.reloadData()
                    completion(response: test1)
                    }
                    */
                }
                    
                    
                    // If there is an error.....
                else if (error != nil){
                    println("error!")
                }
            }
        }
    }
    
    class func getUserSettings(apiEndPoint: String, completionHandler: (response: [Settings]) -> ()) {
        // Making GET request to the URL
        request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            
            // Making sure if the JSON is not empty
            if (json != nil) {
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)

                // Make new JSON array
                if let appArray = jsonObj["feed"]["entry"].array {
                    
                    var settingsArray = [Settings]()
                    
                    // Check for every app in the array
                    for appDict in appArray {
                        
                        // Making new Object for putting in the array
                        var newSettings = Settings()
                        
                        // Set name inside the object
                        var accessibility: Int = appDict["subject"].intValue
                        newSettings.setUserHasAccessibility(accessibility)
                        
                        // Set the website for the object
                        var speech: Int = appDict["subject"].intValue
                        newSettings.setUserHasSpeech(speech)
                        
                        // Append the app names
                        settingsArray.append(newSettings)
                        
                    }
                    
                    // Give the array back to the main Thread
                    completionHandler(response: settingsArray)
                    
                    /* Code snippet for getting single item out of JSON array
                    if let appName = jsonObj["feed"]["entry"][1]["im:name"]["label"].string{
                    let test1 = Test(age: 9, name: appName)
                    //self.tableView.reloadData()
                    completion(response: test1)
                    }
                    */
                }
                    
                    
                    // If there is an error.....
                else if (error != nil){
                    println("error!")
                }
            }
        }
    }
    
    /* Prototype function
    class func appendMessages(apiEndPoint: String, items: [Message], completionHandler: (response: [Message]) -> ()) {
    
    // Making GET request to the URL
    request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
    
    // Making sure if the JSON is not empty
    if (json != nil) {
    
    // Making the JSON object from the JSON
    var jsonObj = JSON(json!)
    
    
    
    // Make new JSON array
    if let appArray = jsonObj["feed"]["entry"].array {
    
    var messageArray = [Message]()
    var i = 0
    
    
    // Check for every app in the array
    for appDict in appArray {
    
    // Making new Object for putting in the array
    var newMessage = Message()
    
    // Set name inside the object
    var appName: String = appDict["subject"].stringValue
    newMessage.setName(appName)
    
    // Set the website for the object
    var appURL: String = appDict["message"].stringValue
    newMessage.setWebsite(appURL)
    
    //println("Nothing "  + newMessage.getName() )
    // println("Array " + items[i].getName())
    
    if((items.get(i)) == nil){
    messageArray.append(newMessage)
    println("NUMAGHET")
    }
    
    
    i++
    }
    
    // Give the array back to the main Thread
    completionHandler(response: messageArray)
    
    /* Code snippet for getting single item out of JSON array
    if let appName = jsonObj["feed"]["entry"][1]["im:name"]["label"].string{
    let test1 = Test(age: 9, name: appName)
    //self.tableView.reloadData()
    completion(response: test1)
    }
    */
    }
    
    
    // If there is an error.....
    else if (error != nil){
    println("error!")
    }
    }
    }
    }*/
}


