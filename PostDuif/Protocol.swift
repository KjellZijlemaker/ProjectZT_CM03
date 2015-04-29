//
//  protocol.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

protocol deleteMessageItem {
    func executeDeletionTimer(String, String)
}

protocol messageOpenend{
    var messageIsOpenend: Bool{
        get set
    }
}

protocol clubNewsDelegate{
    var speech:SpeechManager!{
        get set
    }
    func dismissController()
    
}

protocol messagesDelegate{
    var speech:SpeechManager!{
        get set
    }
    func dismissController()
}

protocol newsMessagesDelegate{
    var speech:SpeechManager!{
        get set
    }
    func dismissController()
}
