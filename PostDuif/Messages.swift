//
//  TestObject.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Message{
    
    var subject: String
    var content: String
    var category: String

    init(){
        self.subject = ""
        self.content = ""
        self.category = ""
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
    
}