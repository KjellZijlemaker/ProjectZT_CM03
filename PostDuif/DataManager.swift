//
//  DataManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Manager for getting data and checking messages read

import Foundation

class DataManager{
    
    class func getItems(apiEndPoint: String, completionHandler: (response: [Item]) -> ()) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 10 // seconds
        
        var alamofireManager = Manager(configuration: configuration)
        
        // Making GET request to the URL
        alamofireManager.request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            println(apiEndPoint)
            
            // Making sure if the JSON is not empty
            if (json != nil) {
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                
                var messageArray = [Item]()
                
                if jsonObj["code"].string == "200"{
                    
                    
                    // Making new array
                    if let dataArray = jsonObj["data"]["entry"].array{
                        
                        for messages in dataArray{
                            var type: String = messages["type"].stringValue
                            if(type == "1"){
                                
                                // Making new Message object
                                var newMessage = Item()
                                
                                // Setting returncode
                                var returnCode = jsonObj["code"].stringValue
                                newMessage.setReturnCode(returnCode)
                                
                                // Setting returncode
                                newMessage.setType(type)
                                
                                // Setting the message ID
                                var messageID: String = messages["messageId"].stringValue
                                newMessage.setID(messageID)
                                
                                // Setting the name of the user that send the message
                                var fromUser: String = messages["fromUser"].stringValue
                                newMessage.setFromUser(fromUser)
                                
                                // Set name inside the object
                                var messageName: String = messages["subject"].stringValue
                                newMessage.setSubject(messageName)
                                
                                // Set the website for the object
                                var messageContent: String = messages["message"].stringValue
                                newMessage.setContent(messageContent)
                                
                                var publishDate: String = messages["addedDate"].stringValue
                                newMessage.setPublishDate(publishDate)
                                
                                var attachment: String = messages["attachment"]["attachment_0"]["filekey"].stringValue
                                if(attachment != ""){
                                    newMessage.setAttachment(attachment)
                                }
                                
                                var attachmentDescription: String = messages["attachment"]["attachment_0"]["fileDescription"].stringValue
                                if(attachmentDescription != ""){
                                    newMessage.setAttachmentDescription(attachmentDescription)
                                }
                                
                                // Set the profile picture
                                var fromUserProfilePictureURL: String = messages["fromUserProfilePictureURL"].stringValue
                                newMessage.setFromUserProfilePictureURL(fromUserProfilePictureURL)
                                
                                
                                // Append the app names
                                messageArray.append(newMessage)
                                
                            }
                                
                                
                            else if (type == "2"){
                                // Making new Message object
                                var newMessage = Item()
                                
                                // Setting returncode
                                var returnCode = jsonObj["code"].stringValue
                                newMessage.setReturnCode(returnCode)
                                
                                // Setting type
                                newMessage.setType(type)
                                
                                // Setting the message ID
                                var newsFeedID: String = messages["newsFeedItemMessageId"].stringValue
                                newMessage.setID(newsFeedID)
                                
                                // Set name inside the object
                                var newsTitle: String = messages["Title"].stringValue
                                newMessage.setSubject(newsTitle)
                                
                                // Set category inside the object
                                var newsCategory: String = messages["category"].stringValue
                                newMessage.setCategory(newsCategory)
                                
                                // Set the website for the object
                                var newsContent: String = messages["content"].stringValue
                                newMessage.setContent(newsContent)
                                
                                var publishDate: String = messages["addedDate"].stringValue
                                newMessage.setPublishDate(publishDate)
                                
                                // Append the app names
                                messageArray.append(newMessage)
                            }
                                
                            else if(type == "3"){
                                // Making new Message object
                                var newMessage = Item()
                                
                                // Setting returncode
                                var returnCode = jsonObj["code"].stringValue
                                newMessage.setReturnCode(returnCode)
                                
                                // Setting type
                                newMessage.setType(type)
                                
                                // Setting the message ID
                                var clubMessageID: String = messages["clubMessageClientId"].stringValue
                                newMessage.setID(clubMessageID)
                                
                                // Set name inside the object
                                var clubMessageSubject: String = messages["subject"].stringValue
                                newMessage.setSubject(clubMessageSubject)
                                
                                // Set the website for the object
                                var clubMessage: String = messages["message"].stringValue
                                newMessage.setContent(clubMessage)
                                
                                var publishDate: String = messages["addedDate"].stringValue
                                newMessage.setPublishDate(publishDate)
                                
                                var clubType: String = messages["clubType"].stringValue
                                newMessage.setClubType(clubType)
                                
                                var clubName: String = messages["clubName"].stringValue
                                newMessage.setClubName(clubName)
                                
                                // Append the app names
                                messageArray.append(newMessage)
                            }
                            
                        }
                        
                    }
                }
                else{
                    if let returnCode = jsonObj["code"].string{
                        var newMessage = Item()
                        newMessage.setReturnCode(returnCode)
                        messageArray.append(newMessage)
                    }
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
                // Making new Message object
                var newMessage = Item()
                newMessage.setReturnCode("403")
                var messageArray = [Item]()
                messageArray.append(newMessage)
                
                // Give the array back to the main Thread
                completionHandler(response: messageArray)
            }
        }
        
        
    }
    
    
    class func checkMessageRead(apiEndPoint: String, completionHandler: (response: String) -> ()) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 10 // seconds
        
        var alamofireManager = Manager(configuration: configuration)
        
        // Making GET request to the URL
        alamofireManager.request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            if (json != nil) {
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                
                if let code = jsonObj["code"].string{
                    completionHandler(response: code)
                }
            }
        }
    }
}


