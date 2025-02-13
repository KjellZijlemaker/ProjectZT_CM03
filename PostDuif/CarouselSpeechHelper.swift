//
//  CarouselView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Helper class for speeching.

import Foundation

class CarouselSpeechHelper{
    private var speech:SpeechManager!
    private var userSettings:Settings!
    var delegate: carouselDelegate!
    
    /**
    Init for setting the speech and userSettings, when the speech already exists inside any other controller
    
    :param: speech Is the manager inside the controller
    :param: userSettings Are the settings inside the controller
    */
    init(speech: SpeechManager, userSettings: Settings){
        self.speech = speech
        self.userSettings = userSettings
    }
    
    /**
    Init for setting the speech and userSettings, when the speech does not exist inside any other controller
    
    :param: speech Is the manager inside the controller
    :param: userSettings Are the settings inside the controller
    */
    init(userSettings: Settings){
        self.speech = SpeechManager()
        self.userSettings = userSettings
    }
    
    /**
    Function for speeching the item from the position of the Carousel
    
    :param: index The position of the item to be speeched
    */
    func carouselSpeechItem(index: Int){
        
        // If the currentItemIndex is 0, the categoryView should behave differently
        if (index == 0) {
            self.delegate.carousel.reloadData()
            
            self.delegate.categoryView.hidden = false // Unhide view
            self.delegate.setCategoryType(index, isEmpty: false) // Setting the category type
            
            self.delegate.firstItem = false
        }
        
        // Will execute when it's not the first item anymore (for speech)
        if(!self.delegate.firstItem){
            
            var textToSend:[String] = [] // Array for sending message
            
            // Check if the item is message or newsitem
            if(self.delegate.items[index].getType() == "1"){
                var currentItem = self.delegate.messagesCount - self.delegate.messagesCount + index + 1
                var read = "Ongelezen"
                var numberOfItems = ""
                
                // If the item is read, the text should change
                if(self.delegate.items[index].isRead()){
                    read = "Gelezen"
                }
                else{
                    numberOfItems = String(currentItem) + "e "
                }
                
                // Making the text to speech
                if(self.userSettings.isSpeechEnabled() || UIAccessibilityIsVoiceOverRunning()){
                    textToSend.append(numberOfItems + read + " bericht van: " + self.delegate.items[index].getFromUser())
                    textToSend.append("Onderwerp: " + self.delegate.items[index].getSubject())
                    println(self.userSettings.isHintSupportSoundEnabled())
                    if(self.userSettings.isHintSupportSoundEnabled()){
                        textToSend.append("Tik op het scherm om het bericht te openen")
                    }
                }
                self.speech.speechArray(textToSend) // Speech the text
            }
                
            else if(self.delegate.items[index].getType() == "2"){
                var currentItem = self.delegate.carousel.currentItemIndex - self.delegate.messagesCount - self.delegate.clubNewsCount + 1
                var read = "Ongelezen"
                var numberOfItems = ""
                
                // If the item is read, the text should change
                if(self.delegate.items[index].isRead()){
                    read = "Gelezen"
                }
                else{
                    numberOfItems = String(currentItem) + "e "
                }
                
                // Making the text to speech
                if(self.userSettings.isSpeechEnabled() || UIAccessibilityIsVoiceOverRunning()){
                    textToSend.append(numberOfItems + read + " nieuwsbericht")
                    textToSend.append("Titel: " + self.delegate.items[index].getSubject())
                    if(self.userSettings.isHintSupportSoundEnabled()){
                        textToSend.append("Tik op het scherm om het nieuwsbericht te openen")
                    }
                }
                
                self.speech.speechArray(textToSend)// Speech the text
            }
            else if(self.delegate.items[index].getType() == "3"){
                var currentItem = self.delegate.carousel.currentItemIndex - self.delegate.messagesCount + 1
                var read = "Ongelezen "
                var numberOfItems = ""
                
                // If the item is read, the text should change
                if(self.delegate.items[index].isRead()){
                    read = "Gelezen "
                }
                else{
                    numberOfItems = String(currentItem) + "e "
                }
                
                // Making the text to speech
                if(self.userSettings.isSpeechEnabled() || UIAccessibilityIsVoiceOverRunning()){
                    textToSend.append(numberOfItems + read + self.delegate.items[index].getClubType() + "-bericht " +  "van: " + self.delegate.items[index].getClubName())
                    textToSend.append("Titel: " + self.delegate.items[index].getSubject())
                    if(self.userSettings.isHintSupportSoundEnabled()){
                        textToSend.append("Tik op het scherm om het " + self.delegate.items[index].getClubType() + " bericht te openen")
                    }
                }
                
                self.speech.speechArray(textToSend)// Speech the text
            }
            
            self.delegate.carousel.reloadItemAtIndex(self.delegate.carousel.currentItemIndex, animated: false) // Reload the item at index for optional updates inside the carousel item
        }
    }
    
    /**
    Function for special speeching the scrolling message (currently only the personal messages) without using the carouselSpeechItem. This is because the carouselScrollToIndex method will speech all the previous items, while only the selected should be speeched.
    
    :param: index The index position of the scrolling item to be speeched
    */
    func speechCarouselScrollItem(index: Int){
        
        var textToSend:[String] = [] // Array for sending message

        // Check if the item is message or newsitem
        if(self.delegate.items[index].getType() == "1"){
            var currentItem = self.delegate.messagesCount - self.delegate.messagesCount + index + 1
            var read = "Ongelezen"
            var numberOfItems = ""
            
            // If the item is read, the text should change
            if(self.delegate.items[index].isRead()){
                read = "Gelezen"
            }
            else{
                numberOfItems = String(currentItem) + "e "
            }
            
            // Making the text to speech
            if(self.userSettings.isSpeechEnabled() || UIAccessibilityIsVoiceOverRunning()){
                textToSend.append(numberOfItems + read + " bericht van: " + self.delegate.items[index].getFromUser())
                textToSend.append("Onderwerp: " + self.delegate.items[index].getSubject())
                println(self.userSettings.isHintSupportSoundEnabled())
                if(self.userSettings.isHintSupportSoundEnabled()){
                    textToSend.append("Tik op het scherm om het bericht te openen")
                }
            }
            self.speech.speechArray(textToSend) // Speech the text
        }

    }
    
    /**
    Function for speeching the total of new items to the user
    
    :param: newItems Total of new items to be speeched
    :param: type The type of message to be speeched
    */
    func newItemsToSpeech(newItems: Int, type: String){
        var newMessageSpeechString = ""
        var typeItem = ""
        
        // Checking to type to speech type
        switch(type){
        case "1":
            // Small check for grammar
            if(newItems == 1){
                typeItem = " nieuw bericht"
            }
            else{
                typeItem = " nieuwe berichten"
            }
            break
        case "2":
            // Small check for grammar
            if(newItems == 1){
                typeItem = " nieuw nieuwsbericht"
            }
            else{
                typeItem = " nieuwe nieuwsberichten"
            }
            break
        case "3":
            // Small check for grammar
            if(newItems == 1){
                typeItem = " nieuw club, of organisatiebericht"
            }
            else{
                typeItem = " nieuwe club, of organisatieberichten"
            }
            break
        default:
            break
        }
        
        self.speech.speechSynthesizer.pauseSpeakingAtBoundary(.Immediate) // Pause the old speech
        
        // Make new speech for speeching new items
        var speech = SpeechManager()
        newMessageSpeechString = "U heeft: " + String(newItems) + typeItem // Making new speech string
        speech.speechString(newMessageSpeechString) // Say the speech
        
        // Check if speech is still speaking, if not continue speaking
        if(!speech.isSpeaking()){
            self.speech.speechSynthesizer.continueSpeaking()
        }
        
    }
    
    /**
    Function for speeching that there are no more items available inside the Carousel
    */
    func speechNoItemsAvailable(){
        self.speech.speechString("Er zijn geen nieuwe berichten op dit moment.")
    }
    
    
    /**
    Function for speeching the total of items inside the carousel, per type of item.
    Different from the newItemsToSpeech is that every typeset of items will be speeched
    
    :param: messageCount the total of messages
    :param: clubNewsCount the total of clubnews
    :param: newsCount the total of news
    */
    func speechTotalItemsAvailable(messagesCount: Int, clubNewsCount: Int, newsCount: Int){
        // default sentences
        var vocabFixMessages = " berichten"
        var vocabFixClubNews = " club, of organisatieberichten"
        var vocabFixNews = " nieuwsberichten"
        
        // Check if sentences should be corrected
        if(messagesCount == 1){
            vocabFixMessages = " bericht"
        }
        if(clubNewsCount == 1){
            vocabFixClubNews = " club, of organisatiebericht"
        }
        if(newsCount == 1){
            vocabFixNews = " nieuwsbericht"
        }
        
        // Making new sentence
        var sentenceArray: [String] = []
        sentenceArray.append("U heeft in totaal: " + String(messagesCount) + vocabFixMessages + ", ")
        sentenceArray.append(String(clubNewsCount) + vocabFixClubNews)
        sentenceArray.append(" en" + String(newsCount) + vocabFixNews)
        
        self.speech.speechArray(sentenceArray) // Speech the sentence
    }
    
    /**
    Function for speeching the current message to the user from a controller
    
    :param: message Is the object where all the info is to be speeched
    */
    func speechMessageItem(message: Item){
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Onderwerp bericht: " + message.getSubject())
        sentenceArray.append("Inhoud bericht: ")
        sentenceArray.append(message.getContent())
        if(message.getAttachmentDescription() != ""){
            sentenceArray.append("Beschrijving foto: ")
            sentenceArray.append(message.getAttachmentDescription())
        }
        sentenceArray.append("Einde bericht")
        if(self.userSettings.isHintSupportSoundEnabled()){
            sentenceArray.append("Veeg naar links om het bericht te sluiten")
        }
        
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    
    /**
    Function for speeching the current newsItem to the user from a controller
    
    :param: news Is the object where all the info is to be speeched
    */
    func speechNewsMessageItem(news: Item){
        
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Titel nieuwsbericht: " + news.getSubject())
        sentenceArray.append("Inhoud nieuwsbericht: ")
        sentenceArray.append(news.getContent())
        sentenceArray.append("Einde nieuwsbericht")
        if(self.userSettings.isHintSupportSoundEnabled()){
            sentenceArray.append("Veeg naar links om het nieuwsbericht te sluiten")
        }
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    
    /**
    Function for speeching the current clubnews to the user from a controller
    
    :param: clubNews Is the object where all the info is to be speeched
    */
    func speechClubNewsItem(clubNews: Item){
        
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Titel " + clubNews.getClubType() + "-bericht: " + clubNews.getSubject())
        sentenceArray.append("Inhoud " + clubNews.getClubType() + "-bericht: ")
        sentenceArray.append(clubNews.getContent())
        sentenceArray.append("Einde " + clubNews.getClubType() + "-bericht")
        if(self.userSettings.isHintSupportSoundEnabled()){
            sentenceArray.append("Veeg naar links om het " + clubNews.getClubType() + "-bericht te sluiten")
        }
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    /**
    Function for getting speech for manual using the object
    
    :param: message Is the object where all the info is to be speeched
    :returns: speechManager The manager context
    */
    func getSpeech() -> SpeechManager{
        return speech
    }
    
}