//
//  CarouselView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class CarouselSpeechHelper{
    private var speech:SpeechManager!
    var delegate: carouselDelegate!
    
    // SingleTon speechmanager
    init(){
        self.speech = SpeechManager()
    }
    
    // If the item is first in the carousel
    func firstItemInCarousel(){
        
        /*
        First Total of items + first message will be played
        */
        
        if (self.delegate.carousel.currentItemIndex == 0) {
            self.delegate.carousel.reloadData()
            
            self.delegate.categoryView.hidden = false // Unhide view
            self.delegate.setCategoryType(self.delegate.carousel.currentItemIndex, isEmpty: false) // Setting the category type
            
            self.delegate.firstItem = false
            
            if(self.delegate.userSettings.isSpeechEnabled()){
                var textToSend:[String] = [] // Array for sending message
                
                // Check if the item is message or newsitem
                if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "1"){
                    
                    textToSend.append(String(self.delegate.carousel.currentItemIndex+1) + "e " + " Ongelezen bericht van: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getFromUser())
                    textToSend.append("Onderwerp: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om het bericht te openen")
                    
                    self.speech.speechArray(textToSend)
                }
                else if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "2"){
                    
                    textToSend.append(String(self.delegate.carousel.currentItemIndex+1) + "e " + " Ongelezen nieuwsbericht")
                    textToSend.append("Titel: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                    
                    self.speech.speechArray(textToSend)
                }
                else if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "3"){
                    
                    textToSend.append(String(self.delegate.carousel.currentItemIndex+1) + "e " + " Ongelezen nieuwsbrief")
                    textToSend.append("Titel: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om de nieuwsbrief te openen")
                    
                    self.speech.speechArray(textToSend)
                }
            }
        }
    }
    
    
    // Speech the current item inside the carousel
    
    func carouselSpeechItem(){
        
        // Will execute when it's not the first item anymore (for speech)
        if(!self.delegate.firstItem){
            if(self.delegate.userSettings.isSpeechEnabled()){
                
                var textToSend:[String] = [] // Array for sending message
                
                // Check if the item is message or newsitem
                if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "1"){
                    
                    var currentItem = self.delegate.messagesCount - self.delegate.messagesCount + self.delegate.carousel.currentItemIndex + 1
                    
                    textToSend.append(String(self.delegate.carousel.currentItemIndex+1) + "e " + " Ongelezen bericht van: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getFromUser())
                    textToSend.append("Onderwerp: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om het bericht te openen")
                    
                    self.speech.speechArray(textToSend)
                }
                    
                else if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "2"){
                    
                    var currentItem = self.delegate.carousel.currentItemIndex - self.delegate.messagesCount - self.delegate.clubNewsCount + 1
                    
                    textToSend.append(String(currentItem) + "e " + " Ongelezen nieuwsbericht")
                    textToSend.append("Titel: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                    
                    self.speech.speechArray(textToSend)
                }
                else if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "3"){
                    
                    var currentItem = self.delegate.carousel.currentItemIndex - self.delegate.messagesCount + 1
                    
                    textToSend.append(String(currentItem) + "e " + " Ongelezen nieuwsbrief")
                    textToSend.append("Titel: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                    textToSend.append("Tik op het scherm om de nieuwsbrief te openen")
                    
                    self.speech.speechArray(textToSend)
                }
            }
            self.delegate.carousel.reloadItemAtIndex(self.delegate.carousel.currentItemIndex, animated: false)
        }
    }
    
    //# MARK: - Extra speech methods
    //=================================================================================================
    //TODO: Make background stop speech
    func newItemsToSpeech(newItems: Int, type: String){
        var newMessageSpeechString = ""
        var typeItem = ""
        if(type == "1"){
            // Small check for grammar
            if(newItems == 1){
                typeItem = "bericht"
            }
            else{
                typeItem = "berichten"
            }
        }
        else if(type == "2"){
            // Small check for grammar
            if(newItems == 1){
                typeItem = "nieuwsbericht"
            }
            else{
                typeItem = "nieuwsberichten"
            }
        }
        else if(type == "3"){
            // Small check for grammar
            if(newItems == 1){
                typeItem = "nieuwsbrief"
            }
            else{
                typeItem = "nieuwsbrieven"
            }
        }
        
        newMessageSpeechString = "U heeft: " + String(newItems) + "nieuwe " + typeItem
        
        self.getSpeech().speechString(newMessageSpeechString) // Say the speech
        
        //self.carousel.reloadItemAtIndex(self.messages.count, animated: true) // Reload only the last item
        
    }
    
    func speechNoItemsAvailable(){
        self.speech.speechString("Er zijn geen nieuwe berichten op dit moment.")
    }
    
    func getSpeech() -> SpeechManager{
        return speech
    }

}