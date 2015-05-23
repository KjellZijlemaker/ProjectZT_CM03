//
//  protocol.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-03-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

protocol deleteMessageItem {
    func deleteMessage(String, String)
}

protocol messageOpenend{
    var messageIsOpenend: Bool{
        get set
    }
}

protocol userManagerDelegate{
    var token: Token{
        get set
    }
    func getUserSettings(tokenKey: String, updateSettings: Bool)
}

protocol dataManagerDelegate{
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

protocol messagesContentTextViewDelegate{
    var delegate: messagesDelegate!{
        get set
    }
}

protocol newsMessagesContentTextViewDelegate{
    var delegate: newsMessagesDelegate!{
        get set
    }
}

protocol clubNewsContentTextViewDelegate{
    var delegate: clubNewsDelegate!{
        get set
    }
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
    func appendAppData(type: String, showLoadingScreen: Bool, shouldScrollToMessage: Bool)
    var firstItem:Bool{
        get set
    }
    var items:[Item]{
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
