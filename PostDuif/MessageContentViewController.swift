//
//  ContentView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class MessageContentViewController: UIViewController, messagesDelegate {
    var message:Item!
    var userSettings:Settings!
    var speech:SpeechManager!
    var deletingMessage: deleteMessageItem!
    var openendMessage: messageOpenend!
    
    @IBOutlet var messagesView: MessagesView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view
        self.messagesView.delegate = self
        self.messagesView.setupTitle()
        self.messagesView.setupContent()
        self.messagesView.setupSwiping()
        
        // Setting the text
        self.messagesView.setTitleText(self.message.getSubject())
        self.messagesView.setMessageText(self.message.getContent())//Putting back the message inside the controller
        
        // Setting the color and backround
        if(self.userSettings.getColorType() != "default"){
            self.messagesView.setViewBackground(self.userSettings.getColorType())
        }
        if(self.userSettings.getContrastType() != "default"){
            
        }
        
        if(self.userSettings.isSpeechEnabled()){
            self.speechMessageItem()
        }
        
        
    }
    
    func speechMessageItem(){
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Onderwerp bericht: " + self.message.getSubject())
        sentenceArray.append("Inhoud bericht: ")
        sentenceArray.append(self.message.getContent())
        sentenceArray.append("Einde bericht")
        sentenceArray.append("Veeg naar links om het bericht te sluiten")
        
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    func dismissController(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            if(self.userSettings.isSpeechEnabled()){
                self.speech.speechString("U heeft het bericht gelezen") //Little speech for user
            }
            self.openendMessage.messageIsOpenend = false
            self.deletingMessage.executeDeletionTimer(self.message.getID(), "1")
        });
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
