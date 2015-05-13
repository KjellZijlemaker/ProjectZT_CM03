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
    
    // If speech already exist
    init(speech: SpeechManager){
        self.speech = speech
    }
    
    // SingleTon speechmanager
    init(){
        self.speech = SpeechManager()
    }
    
    // Speech the current item inside the carousel
    
    func carouselSpeechItem(){
        if (self.delegate.carousel.currentItemIndex == 0) {
            self.delegate.carousel.reloadData()
            
            self.delegate.categoryView.hidden = false // Unhide view
            self.delegate.setCategoryType(self.delegate.carousel.currentItemIndex, isEmpty: false) // Setting the category type
            
            self.delegate.firstItem = false
        }
        
        // Will execute when it's not the first item anymore (for speech)
        if(!self.delegate.firstItem){
            
                
                var textToSend:[String] = [] // Array for sending message
                
                // Check if the item is message or newsitem
                if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "1"){
                    
                    var currentItem = self.delegate.messagesCount - self.delegate.messagesCount + self.delegate.carousel.currentItemIndex + 1
                    
                    if(UIAccessibilityIsVoiceOverRunning() || self.delegate.userSettings.isSpeechEnabled()){
                        textToSend.append(String(self.delegate.carousel.currentItemIndex+1) + "e " + " Ongelezen bericht van: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getFromUser())
                    }
                    
                    if(!UIAccessibilityIsVoiceOverRunning() && self.delegate.userSettings.isSpeechEnabled()){
                        textToSend.append("Onderwerp: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                        textToSend.append("Tik op het scherm om het bericht te openen")
                    }
                    
                    self.speech.speechArray(textToSend)
                }
                    
                else if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "2"){
                    
                    var currentItem = self.delegate.carousel.currentItemIndex - self.delegate.messagesCount - self.delegate.clubNewsCount + 1
                    if(UIAccessibilityIsVoiceOverRunning() || self.delegate.userSettings.isSpeechEnabled()){
                        textToSend.append(String(currentItem) + "e " + " Ongelezen nieuwsbericht")
                    }
                    if(!UIAccessibilityIsVoiceOverRunning() && self.delegate.userSettings.isSpeechEnabled()){
                        textToSend.append("Titel: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                        textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                    }
                    
                    self.speech.speechArray(textToSend)
                }
                else if(self.delegate.items[self.delegate.carousel.currentItemIndex].getType() == "3"){
                    
                    var currentItem = self.delegate.carousel.currentItemIndex - self.delegate.messagesCount + 1
                    if(UIAccessibilityIsVoiceOverRunning() || self.delegate.userSettings.isSpeechEnabled()){
                        textToSend.append(String(currentItem) + "e " + " Ongelezen nieuwsbrief")
                    }
                    if(!UIAccessibilityIsVoiceOverRunning() && self.delegate.userSettings.isSpeechEnabled()){
                        textToSend.append("Titel: " + self.delegate.items[self.delegate.carousel.currentItemIndex].getSubject())
                        textToSend.append("Tik op het scherm om de nieuwsbrief te openen")
                    }
                    
                    self.speech.speechArray(textToSend)
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
    
    // Speech club news item
    func speechClubNewsItem(clubNews: Item){
        
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Titel nieuwsbrief: " + clubNews.getSubject())
        sentenceArray.append("Inhoud nieuwsbrief: ")
        sentenceArray.append(clubNews.getContent())
        sentenceArray.append("Einde nieuwsbrief")
        sentenceArray.append("Veeg naar links om het nieuwsbrief te sluiten")
        
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    // Speech news item
    func speechNewsMessageItem(news: Item){
        
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Titel nieuwsbericht: " + news.getSubject())
        sentenceArray.append("Inhoud nieuwsbericht: ")
        sentenceArray.append(news.getContent())
        sentenceArray.append("Einde nieuwsbericht")
        sentenceArray.append("Veeg naar links om het nieuwsbericht te sluiten")
        
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    // Speech message item
    func speechMessageItem(message: Item){
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Onderwerp bericht: " + message.getSubject())
        sentenceArray.append("Inhoud bericht: ")
        sentenceArray.append(message.getContent())
        sentenceArray.append("Einde bericht")
        sentenceArray.append("Veeg naar links om het bericht te sluiten")
        
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    func getSpeech() -> SpeechManager{
        return speech
    }

}