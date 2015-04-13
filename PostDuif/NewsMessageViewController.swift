//
//  NewsContentViewController.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 15-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class NewsMessageViewController: UIViewController {
    var message:Message!
    var speech:SpeechManager = SpeechManager()
    var delegate: deleteMessageItem!
    var openendMessage: messageOpenend!
    var deletingMessage: deleteMessageItem!
    var carouselID: String!
    var speechEnabled: Bool = true
    

    @IBOutlet weak var newsMessageTitle: UITextView!
    @IBOutlet weak var newsMessageText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.newsMessageTitle.layer.cornerRadius = 8
        self.newsMessageTitle.text = self.message.getSubject()
        self.newsMessageText.layer.cornerRadius = 8
        self.newsMessageText.text = self.message.getContent() //Putting back the message inside the controller
        
        if(self.speechEnabled){
            
            // Making new sentence array for speech
            var sentenceArray: [String] = []
            sentenceArray.append("Titel nieuwsbericht: " + self.message.getSubject())
            sentenceArray.append("Inhoud nieuwsbericht: ")
            sentenceArray.append(self.newsMessageText.text)
            sentenceArray.append("Einde nieuwsbericht")
            sentenceArray.append("Veeg naar rechts om het nieuwsbericht te sluiten")
            
            self.speech.speechArray(sentenceArray) //Execute speech
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //------------Swipe method to the right--------------//
    func rightSwiped(){
        self.speech.stopSpeech() //Stop speech
      
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            if(self.speechEnabled){
                self.speech.speechString("U heeft het nieuwsbericht gelezen") //Little speech for user
            }
            self.delegate.executeDeletionTimer(self.carouselID, "2")
        });
    }
    

}
