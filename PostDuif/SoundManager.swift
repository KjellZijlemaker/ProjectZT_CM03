//
//  SoundManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 30-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Manager for playing the desired sounds

import Foundation
import AVFoundation

class SoundManager{
    var audioSound: NSURL!
    var audioPlayer:AVAudioPlayer!
    
    /**
    Constructor for making a new sound object
    
    :param: resourcePath Path of the resource
    :param: fileType The type of file to be loaded
    */
    init(resourcePath: String, fileType: String){
        self.audioSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(resourcePath, ofType: fileType)!)
    }
    
    /**
    Function for stopping the sound
    */
    func stopSound(){
        self.audioPlayer.stop()
    }
    
    /**
    Function for playing the sound
    */
    func playSound(){
        self.audioPlayer = AVAudioPlayer(contentsOfURL: audioSound, error: nil)
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.volume = 1.0
        self.audioPlayer.play()
    }
    
    /**
    Function to check if the sound is playing or not
    */
    func soundIsPlaying() -> Bool{
        return self.audioPlayer.playing
    }
    
}

