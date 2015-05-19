//
//  AccessibilityHelper.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 09-05-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Helper class for accessibility

import Foundation

class CarouselAccessibilityHelper{
    
    //Accessibility elements
    func checkMessageTypeAccesibility(item: Item) -> String{
        var message = ""
        if(item.getType() == "1"){
            message = "Onderwerp bericht: " + item.getSubject()
            return message
        }
        else if(item.getType() == "2"){
            message = "Onderwerp nieuwsbericht: " + item.getSubject()
            return message
        }
        else if(item.getType() == "3"){
            message = "Onderwerp nieuwsbrief: " + item.getSubject()
            return message
        }
        return ""
    }
}