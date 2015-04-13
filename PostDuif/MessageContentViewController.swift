//
//  ContentView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class MessageContentViewController: UIViewController {
    var message:Message!
    var speech:SpeechManager = SpeechManager()
    var deletingMessage: deleteMessageItem!
    var openendMessage: messageOpenend!
    var carouselID: String!
    var speechEnabled: Bool = true
    
    @IBOutlet weak var messageTitleText: UITextView!
    @IBOutlet weak var messageText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.messageTitleText.layer.cornerRadius = 8
        self.messageTitleText.text = self.message.getSubject()
        self.messageText.layer.cornerRadius = 8
        self.messageText.text = self.message.getContent() //Putting back the message inside the controller
        
        if(self.speechEnabled){
            
            // Making new sentence array for speech
            var sentenceArray: [String] = []
            sentenceArray.append("Onderwerp bericht: " + self.message.getSubject())
            sentenceArray.append("Inhoud bericht: ")
            sentenceArray.append(self.messageText.text)
            sentenceArray.append("Einde bericht")
            sentenceArray.append("Veeg naar rechts om het bericht te sluiten")
            
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
                self.speech.speechString("U heeft het bericht gelezen") //Little speech for user
            }
            self.openendMessage.messageIsOpenend = false
            self.deletingMessage.executeDeletionTimer(self.carouselID, "1")
        });
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
