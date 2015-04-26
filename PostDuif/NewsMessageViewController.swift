//
//  NewsContentViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 15-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class NewsMessageViewController: UIViewController, newsMessagesDelegate {
    var news:Item!
    var userSettings:Settings!
    var speech:SpeechManager = SpeechManager()
    var delegate: deleteMessageItem!
    var openendMessage: messageOpenend!
    var deletingMessage: deleteMessageItem!
    
    
    @IBOutlet var newsMessagesView: NewsMessageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup view
        self.newsMessagesView.delegate = self
        self.newsMessagesView.setupTitle()
        self.newsMessagesView.setupContent()
        self.newsMessagesView.setupSwiping()
        
        // Setting the text
        self.newsMessagesView.setTitleText(self.news.getSubject())
        self.newsMessagesView.setMessageText(self.news.getContent())//Putting back the message inside the controller
        
        // Setting the background
        self.newsMessagesView.setViewBackground(self.userSettings.getColorType())
        
        
        if(self.userSettings.isSpeechEnabled()){
            self.speechNewsMessageItem()
        }
        
    }
    
    func speechNewsMessageItem(){
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Titel nieuwsbericht: " + self.news.getSubject())
        sentenceArray.append("Inhoud nieuwsbericht: ")
        sentenceArray.append(self.news.getContent())
        sentenceArray.append("Einde nieuwsbericht")
        sentenceArray.append("Veeg naar rechts om het nieuwsbericht te sluiten")
        self.speech.speechArray(sentenceArray) //Execute speech
    }
    
    func dismissController(){
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            if(self.userSettings.isSpeechEnabled()){
                self.speech.speechString("U heeft het nieuwsbericht gelezen") //Little speech for user
            }
            self.delegate.executeDeletionTimer(self.news.getID(), "2")
        });

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
   
}
