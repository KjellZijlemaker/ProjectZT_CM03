//
//  CarouselDataHelper.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 02-05-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
// Helper class for getting data. Will mostly exist from sorting data into the right place

import Foundation

class CarouselDataHelper{
    
    /**
    Function for getting all the ID's and sorting them for getting a new array with non duplicates only. These will be added to the Carousel, inside the viewController
    
    :param: items The array of old items that are already inside the Carousel
    :param: newItems The array of new items that are received by the DataManager
    :param: type The type of item that should be appended to the Carousel
    :returns: Array of Integers (ID's) for using to add new items to the Carousel
    */
    func getAllItemIDs(items: [Item], newItems: [Item], type: String) -> [Int]{
        var idArrayOld: [Int] = []
        var idArrayNew: [Int] = []
        var newIDArray: [Int] = []
        var newArray: [AnyObject] = []
        
        // Getting all the ID's for new ID array
        for j in 0...newItems.count-1{
            
            // If 0, also the news and clubNews should be appended because there is none yet
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