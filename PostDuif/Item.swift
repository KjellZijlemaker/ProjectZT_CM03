//
//  TestObject.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Item{
    
    private var id: String
    private var subject: String
    private var content: String
    private var category: String
    private var returnCode: String
    private var type: String
    private var publishDate: String
    private var read: Bool
    
    // Only for messages
    private var fromUser: String
    private var fromUserProfilePictureURL: String
    
    // Only for attachments
    private var attachment: String
    private var attachmentDescription: String
    
    // Only for clubs
    private var clubType: String
    private var clubName: String

    init(){
        self.id = ""
        self.subject = ""
        self.content = ""
        self.category = ""
        self.returnCode = ""
        self.type = ""
        self.publishDate = ""
        self.read = false
        
        // Only for messages
        self.fromUser = ""
        self.fromUserProfilePictureURL = ""
        
        // Only for attachments
        self.attachment = ""
        self.attachmentDescription = ""
        
        // Only for clubs
        self.clubType = ""
        self.clubName = ""
    }
    
    func setID(id: String){
        self.id = id
    }
    
    func getID() -> String{
        return self.id
    }
    
    func setSubject(subject: String){
        self.subject = subject
    }
    
    func setContent(content: String){
        self.content = content
    }
    
    func getSubject() -> String{
        return self.subject
    }
    
    func getContent() -> String{
        return self.content
    }
    
    func setCategory(category: String){
        self.category = category
    }
    
    func getCategory() -> String{
        return self.category
    }
    
    func setReturnCode(returnCode: String){
        self.returnCode = returnCode
    }
    
    func getReturnCode() -> String{
        return self.returnCode
    }
    
    func setFromUser(fromUser: String){
        self.fromUser = fromUser
    }
    
    func getFromUser() -> String{
        return self.fromUser
    }
    
    func setFromUserProfilePictureURL(url: String){
        self.fromUserProfilePictureURL = url
    }
    
    func getFromUserProfilePictureURL() -> String{
        return self.fromUserProfilePictureURL
    }
    
    func setType(type: String){
        self.type = type
    }
    
    func getType() -> String{
        return self.type
    }
    
    func setPublishDate(date: String){
        self.publishDate = date
    }
    
    func getPublishDate() -> String{
        return publishDate
    }
    
    func isRead() -> Bool{
        return self.read
    }
    
    func hasRead(read: Bool){
        self.read = read
    }

    func setAttachment(attachment: String){
        self.attachment = attachment
    }
    
    func getAttachment() -> String{
        return self.attachment
    }
    
    func setAttachmentDescription(attachmentDescription: String){
        self.attachmentDescription = attachmentDescription
    }
    
    func getAttachmentDescription() -> String{
        return self.attachmentDescription
    }
    
    func setClubType(clubType: String){
        self.clubType = clubType
    }
    
    func getClubType() -> String{
        return self.clubType
    }
    
    func setClubName(clubName: String){
        self.clubName = clubName
    }
    
    func getClubName() -> String{
        return self.clubName
    }

    
}