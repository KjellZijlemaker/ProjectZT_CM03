//
//  ContentView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 06-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import UIKit

class MessageContentViewController: UIViewController {
    var messageContent:String!
    var speech:SpeechManager = SpeechManager()
    
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var messageText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        
        self.messageText.text = self.messageContent //Putting back the message inside the controller
        
        // Making new sentence array for speech
        var sentenceArray: [String] = []
        sentenceArray.append("Inhoud bericht: ")
        sentenceArray.append(self.messageContent)
        sentenceArray.append("Einde bericht")
        sentenceArray.append("Veeg naar rechts om het bericht te sluiten")
        
        self.speech.speechArray(sentenceArray) //Execute speech

    }

    //------------Swipe method to the right--------------//
    func rightSwiped(){
        self.speech.stopSpeech() //Stop speech
        
        // Dismiss the controller
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
            let secondPresentingVC = self.presentingViewController?.presentingViewController;
            secondPresentingVC?.dismissViewControllerAnimated(true, completion: {});
            self.speech.speechString("U heeft het bericht gelezen") //Little speech for user
        });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
