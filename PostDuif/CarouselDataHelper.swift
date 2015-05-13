//
//  CarouselDataHelper.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 02-05-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class CarouselDataHelper{
    
    // For getting all the ID's when appending the Items array
    func getAllItemIDs(items: [Item], newItems: [Item], type: String) -> [Int]{
        
        var idArrayOld: [Int] = []
        var idArrayNew: [Int] = []
        var newIDArray: [Int] = []
        var newArray: [AnyObject] = []
        
        // Getting all the ID's for new ID array
        for j in 0...newItems.count-1{
            
            // If 0, also the news should be appended because there is none yet
            if(type != "0"){
                // Check if the type is the same (for appending at the according index)
                if(newItems[j].getType() == type){
                    idArrayNew.append(newItems[j].getID().toInt()!)
                    
                }
            }
            else{
                idArrayNew.append(newItems[j].getID().toInt()!)
            }
            
        }
        
        if(!items.isEmpty){
            // Getting all the ID's for old ID array
            for i in 0...items.count-1{
                
                // If 0, also the news should be appended because there is none yet
                if(type != "0"){
                    
                    // Check if the type is the same (for appending at the according index)
                    if(items[i].getType() == type){
                        idArrayOld.append(items[i].getID().toInt()!)
                    }
                }
                else{
                    idArrayOld.append(items[i].getID().toInt()!)
                }
                
            }
        }
        
        // Making sets
        var set1 = NSMutableSet(array: idArrayOld)
        var set2 = NSMutableSet(array: idArrayNew)
        
        // Getting only the new ID's
        set2.minusSet(set1)
        
        // Putting it into a new array
        newArray = set2.allObjects
        
        // Append all the newID's to the new array
        if(!newArray.isEmpty){
            for k in 0...newArray.count-1{
                newIDArray.append(newArray[k] as Int)
            }
        }
        
        return newIDArray
    }
    
    
}