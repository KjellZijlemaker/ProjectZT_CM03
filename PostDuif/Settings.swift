//
//  Settings.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 18-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class Settings{
    
    var userAccessibility: Int
    var userSpeech: Int
    
    
   // init
    init(){
        self.userAccessibility = 0
        self.userSpeech = 0
    }
    
    func setUserHasAccessibility(userAccessibility: Int){
        self.userAccessibility = userAccessibility
    }
    
    func isUserHasAccessibility() -> Int{
        return self.userAccessibility
    }
    
    func setUserHasSpeech(userSpeech: Int){
        self.userSpeech = userSpeech
    }
    
    func isUserHasSpeech() -> Int{
        return self.userSpeech
    }
}