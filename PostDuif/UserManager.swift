//
//  UserManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 26-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Manager for getting the desired settings for user, from the server

import Foundation

class UserManager{
    
    /**
    Function for logging into the application
    */
    class func loginUser(apiEndPoint: String, completionHandler: (response: Token) -> ()) {
        
        // Making new configuration for some extra settings
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 10 // seconds
        var alamofireManager = Manager(configuration: configuration)
        
        // Making GET request to the URL
        alamofireManager.request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            if (json != nil) {
                
                var token = Token()
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                
                if let code = jsonObj["code"].string{
                    token.setReturnCode(code)
                    
                    // Set the status code
                    if let status = jsonObj["status"].string{
                        token.setStatus(status)
                    }
                    
                    // Set the message from getting the token
                    if let message = jsonObj["message"].string{
                        token.setMessage(message)
                    }
                    
                    // Getting the token for getting new data and settings
                    if let tokenFromArray = jsonObj["data"]["token"].string{
                        token.setToken(tokenFromArray)
                    }
                    
                    // Getting the refreshtoken when the original token doesn't work
                    if let refreshTokenFromArray = jsonObj["data"]["refreshToken"].string{
                        token.setRefreshToken(refreshTokenFromArray)
                    }
                    
                    // Set the expire date
                    if let expireTokenDateFromArray = jsonObj["data"]["expireTokenDate"].string{
                        token.setExpireTokenDate(expireTokenDateFromArray)
                    }
                    
                    
                    
                }
                
                // Send the object back to the main thread
                completionHandler(response: token)
            }
        }
    }
    
    /**
    Function for getting all the settings for the user
    */
    class func getUserSettings(apiEndPoint: String, completionHandler: (response: Settings) -> ()) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 10 // seconds
        
        var alamofireManager = Manager(configuration: configuration)
        
        // Making GET request to the URL
        alamofireManager.request(.GET, apiEndPoint).responseJSON { (request, response, json, error) in
            println(json)
            // Making sure if the JSON is not empty
            if (json != nil) {
                
                // Making the JSON object from the JSON
                var jsonObj = JSON(json!)
                var settingsArray = [Settings]()
                
                if jsonObj["code"].string == "200"{
                    
                    // Making new array
                    if let dataArray = jsonObj["data"]["entry"].array{
                        
                        for settings in dataArray{
                            
                            // Making new Object for putting in the array
                            var newSettings = Settings()
                            
                            newSettings.setReturnCode("200")
                            
                            // Set notification
                            var notification: String = settings["notificationSoundEnabled"].stringValue
                            if(notification == "true"){
                                newSettings.hasNotificationSoundEnabled(true)
                            }
                            else{
                                newSettings.hasNotificationSoundEnabled(false)
                            }
                            
                            // Set endOfMessageSoundEffect
                            var endOfMessageSoundEffect: String = settings["isEndOfMessageSoundEffectEnabled"].stringValue
                            if(endOfMessageSoundEffect == "true"){
                                newSettings.hasEndOfMessageSoundEffectEnabled(true)
                            }
                            else{
                                newSettings.hasEndOfMessageSoundEffectEnabled(false)
                            }
                            
                            
                            // Set totalNewMessageSoundEnabled
                            var totalNewMessageSoundEnabled: String = settings["isTotalNewMessageSoundEnabled"].stringValue
                            if(totalNewMessageSoundEnabled == "true"){
                                newSettings.hasTotalNewMessageSoundEnabled(true)
                            }
                            else{
                                newSettings.hasTotalNewMessageSoundEnabled(false)
                            }
                            
                            // Set HintSupportSoundEnabled
                            var hintSupportSoundEnabled: String = settings["isHintSupportSoundEnabled"].stringValue
                            if(hintSupportSoundEnabled == "true"){
                                newSettings.hasHintSupportSoundEnabled(true)
                            }
                            else{
                                newSettings.hasHintSupportSoundEnabled(false)
                            }
                            
                            // Set message limit
                            var privateMessageLimit: String = settings["ShowPrivateMessageLimit"].stringValue
                            newSettings.setPrivateMessageLimit(privateMessageLimit.toInt()!)
                            
                            // Set speech
                            var speech: String = settings["isSpeechEnabled"].stringValue
                            if(speech == "true"){
                                newSettings.hasSpeechEnabled(true)
                            }
                            else{
                                newSettings.hasSpeechEnabled(false)
                            }
                            
                            // Set news limit
                            var newsMessageLimit: String = settings["ShowNewsMessageLimit"].stringValue
                            newSettings.setNewsMessageLimit(newsMessageLimit.toInt()!)
                            
                            // Set clubNews limit
                            var clubNewsMessageLimit: String = settings["ShowClubMessageLimit"].stringValue
                            newSettings.setClubNewsMessageLimit(clubNewsMessageLimit.toInt()!)
                            
                            // Set color
                            var colorType: String = settings["contrastType"].stringValue
                            
                            // Getting the right colors from one String
                            var primaryColor = colorType.substringToIndex(advance(colorType.startIndex, 6))
                            var secondaryColor = colorType.substringFromIndex(advance(colorType.startIndex, 7))
                            
                            // Setting the colors
                            newSettings.setPrimaryColorType(primaryColor)
                            newSettings.setSecondaryColorType(secondaryColor)
                            
                            // Set accessibility
                            var accessibility: String = settings["accessibilityEnabled"].stringValue
                            if(accessibility == "true"){
                                newSettings.hasAccessibilityEnabled(true)
                            }
                            else{
                                newSettings.hasAccessibilityEnabled(false)
                            }
                            
                            // Store seconds message
                            var messagesStoreMaxSeconds: String = settings["privateMessageStoreTimeSeconds"].stringValue
                            newSettings.setMessagesStoreMaxSeconds(messagesStoreMaxSeconds)
                            
                            // Store seconds clubnews seconds
                            var clubNewsStoreMaxSeconds: String = settings["clubMessageStoreTimeSeconds"].stringValue
                            newSettings.setClubNewsStoreMaxSeconds(clubNewsStoreMaxSeconds)
                            
                            // Store seconds news seconds
                            var newsStoreMaxSeconds: String = settings["newsFeedMessageStoreTimeSeconds"].stringValue
                            newSettings.setNewsStoreMaxSeconds(newsStoreMaxSeconds)
                            
                            var fontSize: String = settings["fontSize"].stringValue
                            var newFontSize: CGFloat = CGFloat(fontSize.toInt()!)
                            newSettings.setFontSize(newFontSize)
                            
                            // Send it back to the main thread
                            settingsArray.append(newSettings)
                            
                        }
                    }
                }
                    // When gone wrong, set the returncode
                else{
                    if let returnCode = jsonObj["code"].string{
                        var newSetting = Settings()
                        newSetting.setReturnCode(returnCode)
                        settingsArray.append(newSetting)
                    }
                }
                
                // Give the array back to the main Thread
                completionHandler(response: settingsArray[0])
            }
                
                
                // If there is an error, set the returncode
            else if (error != nil){
                // Making new Message object
                var newSetting = Settings()
                newSetting.setReturnCode("403")
                
                // Give the array back to the main Thread
                completionHandler(response: newSetting)
            }
        }
    }
}

