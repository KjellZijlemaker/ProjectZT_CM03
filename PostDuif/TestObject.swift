//
//  TestObject.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Test{
    
    var name: String
    var website: String

    init(name: String, website: String){
        self.name = name
        self.website = website
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
    
}