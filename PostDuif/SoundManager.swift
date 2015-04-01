//
//  SoundManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 30-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager{
    var audioSound: NSURL!
    var audioPlayer:AVAudioPlayer!
    
    init(resourcePath: String, fileType: String){
        self.audioSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(resourcePath, ofType: fileType)!)
    }
    
    func stopSound(){
        self.audioPlayer.stop()
    }
    
    func playSound(){
        self.audioPlayer = AVAudioPlayer(contentsOfURL: audioSound, error: nil)
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.volume = 1.0
        self.audioPlayer.play()
    }

    func soundIsPlaying() -> Bool{
        return self.audioPlayer.playing
    }
    
}

