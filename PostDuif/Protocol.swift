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

protocol loginDelegate{
    func sendLoginRequest(String)
}

protocol carouselDelegate{
    var carousel:iCarousel!{
        get set
    }
    var categoryView:CategoryTypeView!{
        get set
    }
    func setCategoryType(index: Int, isEmpty: Bool)
    func appendAppData(type: String, showLoadingScreen: Bool)
    var firstItem:Bool{
        get set
    }
    var userSettings: Settings{
        get set
    }
    var items:[Item]{
        get set
    }
    var totalNewItems: Int{
        get set
    }
    var notificationDot:NotificationDot!{
        get set
    }
    var notificationText:NotificationText!{
        get set
    }
    var messagesCount: Int{
        get set
    }
    var clubNewsCount: Int{
        get set
    }
    var newsCount: Int{
        get set
    }
}
