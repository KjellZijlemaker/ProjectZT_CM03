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
    
    
    /**
    Function for getting data for all items and putting them inside the models
    */
    class func getItems(apiEndPoint: String, completionHandler: (response: [Item]) -> ()) {
        
        // Making new configuration for some extra settings
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
                                
                                if(fromUser != "Null Null"){
                                    newMessage.setFromUser(fromUser)
                                }
                                
                                // Set name inside the object
                                var messageName: String = messages["subject"].stringValue
                                newMessage.setSubject(messageName)
                                
                                // Set the website for the object
                                var messageContent: String = messages["message"].stringValue
                                newMessage.setContent(messageContent)
                                
                                // Setting publishdated for checking when added to Carousel
                                var publishDate: String = messages["addedDate"].stringValue
                                newMessage.setPublishDate(publishDate)
                                
                                // Setting attachment when having a picture
                                var attachment: String = messages["attachment"]["attachment_0"]["filekey"].stringValue
                                if(attachment != ""){
                                    newMessage.setAttachment(attachment)
                                }
                                
                                // Setting the description when present
                                var attachmentDescription: String = messages["attachment"]["attachment_0"]["fileDescription"].stringValue
                                if(attachmentDescription != ""){
                                    newMessage.setAttachmentDescription(attachmentDescription)
                                }
                                
                                // Set the profile picture
                                var fromUserProfilePictureURL: String = messages["fromUserProfilePictureURL"].stringValue
                                newMessage.setFromUserProfilePictureURL(fromUserProfilePictureURL)
                                
                                // Setting if the item has been read or not
                                var hasRead: String = messages["hasRead"].stringValue
                                if(hasRead == "true"){
                                    newMessage.hasRead(true)
                                }
                                else{
                                    newMessage.hasRead(false)
                                }
                                
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
                                
                                // Setting publishdated for checking when added to Carousel
                                var publishDate: String = messages["addedDate"].stringValue
                                newMessage.setPublishDate(publishDate)
                                
                                // Setting if the item has been read or not
                                var hasRead: String = messages["hasRead"].stringValue
                                if(hasRead == "true"){
                                    newMessage.hasRead(true)
                                }
                                else{
                                    newMessage.hasRead(false)
                                }
                                
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
                                
                                // Setting the date when the item has been added
                                var publishDate: String = messages["addedDate"].stringValue
                                newMessage.setPublishDate(publishDate)
                                
                                // Setting the type of club for speeching
                                var clubType: String = messages["clubType"].stringValue
                                newMessage.setClubType(clubType)
                                
                                // Setting the name of club for speeching
                                var clubName: String = messages["clubName"].stringValue
                                newMessage.setClubName(clubName)
                                
                                // Setting if the item has been read or not
                                var hasRead: String = messages["hasRead"].stringValue
                                if(hasRead == "true"){
                                    newMessage.hasRead(true)
                                }
                                else{
                                    newMessage.hasRead(false)
                                }
                                
                                // Append the app names
                                messageArray.append(newMessage)
                            }
                            
                        }
                        
                    }
                }
                    // If the returncode was not 200, there went something wrong. Sent it back to the controller
                else{
                    if let returnCode = jsonObj["code"].string{
                        var newMessage = Item()
                        newMessage.setReturnCode(returnCode)
                        messageArray.append(newMessage)
                    }
                }
                // Give the array back to the main Thread
                completionHandler(response: messageArray)
            }
                
                
                // If there is an error, set return code to 403 and send it back to the controller
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
    
    /**
    Function for checking the items as read. This is important when the message has been read and need to be checked within the website
    */
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


