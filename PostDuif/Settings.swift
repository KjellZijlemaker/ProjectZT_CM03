//
//  Settings.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 18-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Settings{
    
    private var notificationSoundEnabled: Bool
    private var privateMessageLimit: Int
    private var userSpeech: Bool
    private var newsMessageLimit: Int
    private var contrastType: String
    private var colorType: String
    private var userAccessibility: Bool
    private var returnCode: String
    private var messagesStoreMaxSeconds: String
    private var clubMessagesStoreMaxSeconds: String
    private var newsMessagesStoreMaxSeconds: String
    
   // init
    init(){
        self.notificationSoundEnabled = true
        self.privateMessageLimit = 10
        self.userSpeech = true
        self.newsMessageLimit = 10
        self.contrastType = "default"
        self.colorType = "default"
        self.userAccessibility = true
        self.returnCode = ""
        self.messagesStoreMaxSeconds = ""
        self.clubMessagesStoreMaxSeconds = ""
        self.newsMessagesStoreMaxSeconds = ""
    }
    
    func hasNotificationSoundEnabled(notificationSound: Bool){
        self.notificationSoundEnabled = notificationSound
    }
    
    func isNotificationSoundEnabled() -> Bool {
        return self.notificationSoundEnabled
    }
    
    func setPrivateMessageLimit(limit: Int){
        self.privateMessageLimit = limit
    }
    
    func getPrivateMessageLimit() -> Int{
        return self.privateMessageLimit
    }
    
    func hasSpeechEnabled(userSpeech: Bool){
        self.userSpeech = userSpeech
    }
    
    func isSpeechEnabled() -> Bool{
        return self.userSpeech
    }
    
    func setNewsMessageLimit(limit: Int){
        self.newsMessageLimit = limit
    }
    
    func getNewsMessageLimit() -> Int{
        return self.newsMessageLimit
    }
    
    func setContrastType(contrastType: String){
        self.contrastType = contrastType
    }
    
    func getContrastType() -> String{
        return self.contrastType
    }
    
    func setColorType(colorType: String){
        self.colorType = colorType
    }
    
    func getColorType() -> String{
        return self.colorType
    }
    
    func hasAccessibilityEnabled(userAccessibility: Bool){
        self.userAccessibility = userAccessibility
    }
    
    func isAccessibilityEnabled() -> Bool{
        return self.userAccessibility
    }
    
    func setReturnCode(returnCode: String){
        self.returnCode = returnCode
    }
    
    func getReturnCode() -> String{
        return returnCode
    }

    func setMessagesStoreMaxSeconds(maxSeconds: String){
        self.messagesStoreMaxSeconds = maxSeconds
    }
    func getMessagesStoreMaxSeconds() -> String{
        return self.messagesStoreMaxSeconds
    }
    
    func setClubNewsStoreMaxSeconds(maxSeconds: String){
        self.clubMessagesStoreMaxSeconds = maxSeconds
    }
    
    func getClubNewsStoreMaxSeconds() -> String{
        return self.clubMessagesStoreMaxSeconds
    }
    
    func setNewsStoreMaxSeconds(maxSeconds: String){
        self.newsMessagesStoreMaxSeconds = maxSeconds
    }
    
    func getNewsStoreMaxSeconds() -> String{
        return self.newsMessagesStoreMaxSeconds
    }

}