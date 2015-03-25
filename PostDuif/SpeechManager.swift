//
//  Speech.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation
import AVFoundation

class SpeechManager{
    
    // Setup new synthesizer for speech
    let speechSynthesizer: AVSpeechSynthesizer! = AVSpeechSynthesizer()
    
    func speechString(speech: String){
        
        //Setting empty String for bug ios 8
        var bug = " "
        let beforeUtterance = AVSpeechUtterance(string: bug)
        beforeUtterance.rate = AVSpeechUtteranceMaximumSpeechRate
        speechSynthesizer.speakUtterance(beforeUtterance)
        
        let mySpeechUtterance = AVSpeechUtterance(string:speech)
        
        // Setting rate of the voice, bug IOS 8
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
        {
            mySpeechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate;
        }else{
            mySpeechUtterance.rate = 0.06;
        }
        
        mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: "nl-NL")
        println("\(mySpeechUtterance.speechString)")
        
        // Say the sentence
        speechSynthesizer .speakUtterance(mySpeechUtterance)
    }
    
    
    func speechArray(speech: [String]){
        
        for pieceText in speech{
            
            //Setting empty String for bug ios 8
            var bug = " "
            let beforeUtterance = AVSpeechUtterance(string: bug)
            beforeUtterance.rate = AVSpeechUtteranceMaximumSpeechRate
            speechSynthesizer.speakUtterance(beforeUtterance)
            
            
            let mySpeechUtterance = AVSpeechUtterance(string:pieceText)
            
            // Setting rate of the voice, bug IOS 8
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
            {
                mySpeechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate;
            }else{
                mySpeechUtterance.rate = 0.06;
            }
            
            //mySpeechUtterance.rate = 0.06 // Setting rate of the voice
            mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: "nl-NL")
            println("\(mySpeechUtterance.speechString)")
            
            // Say the sentence
            speechSynthesizer .speakUtterance(mySpeechUtterance)
            
            
        }
        
        
    }
    
    func stopSpeech(){
        if(self.speechSynthesizer.speaking){
            self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
            let mySpeechUtterance = AVSpeechUtterance(string:"")
            self.speechSynthesizer.speakUtterance(mySpeechUtterance)
            self.speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        }
        
    }

    func isSpeaking() -> Bool{
        return self.speechSynthesizer.speaking
    }
    
}

    