//
//  SoundManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 30-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation
import AVFoundation

class Sound{
var beepSound: NSURL!
    
    init(resourcePath: String, fileType: String){
        beepSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(resourcePath, ofType: fileType)!)
    }
    
    func stopSound(){
        
    }
    func playSound(){
//        self.beepPlayer = AVAudioPlayer(contentsOfURL: beepSound, error: nil)
//        self.beepPlayer.prepareToPlay()
//        self.beepPlayer.play()
    }

}

