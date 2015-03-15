//
//  TestObject.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Message{
    
    var name: String
    var website: String
    var category: String

    init(name: String, website: String){
        self.name = name
        self.website = website
        self.category = ""
    }
    
    func setName(name: String){
        self.name = name
    }
    
    func setWebsite(website: String){
        self.website = website
    }
    
    func getName() -> String{
        return self.name
    }
    
    func getWebsite() -> String{
        return self.website
    }
    
    func setCategory(category: String){
        self.category = category
    }
    
    func getCategory() -> String{
        return self.category
    }
    
}