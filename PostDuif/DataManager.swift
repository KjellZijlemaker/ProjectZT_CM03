//
//  DataManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class DataManager{
    
    
    class func getMainData(apiEndPoint: String, completion: (response: [Test]) -> ()) {
        
        // Making GET request to the URL
        request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            
            // Making sure if the JSON is not empty
            if (json != nil) {
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                
                
                
                // Make new JSON array
                if let appArray = jsonObj["feed"]["entry"].array {
                    
                    
                    // Check for every app in the array
                    for appDict in appArray {
                        
                        var appsArray = [Test]()
                        
                        // Making new Object for putting in the array
                        var test = Test(name: "", website: "")
                        
                        // Set name inside the object
                        var appName: String = appDict["im:name"]["label"].stringValue
                        test.setName(appName)
                        
                        // Set the website for the object
                        var appURL: String = appDict["im:image"][0]["label"].stringValue
                        test.setWebsite(appURL)
                        
                        // Append the app names
                         appsArray.append(test)
                        
                        // Give the array back to the main Thread
                        completion(response: appsArray)
                        
                    }
                    
                    
                    
                    
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
    
    
}