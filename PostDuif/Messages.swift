//
//  TestObject.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Message{
    
    private var id: String
    private var subject: String
    private var content: String
    private var category: String
    private var returnCode: String
    private var fromUser: String
    private var type: String

    init(){
        self.id = ""
        self.subject = ""
        self.content = ""
        self.category = ""
        self.returnCode = ""
        self.fromUser = ""
        self.type = ""
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
    
    func setType(type: String){
        self.type = type
    }
    
    func getType() -> String{
        return self.type
    }
    
}