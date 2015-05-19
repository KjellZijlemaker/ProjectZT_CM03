//
//  Notification.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  View for the notificationDot

import Foundation

class NotificationDot: UIView{
    private var dot: RSDotsView!
    
    // For drawing custom textField
    override func drawRect(rect: CGRect) {
        
    }
    
    /**
    Function for making the dot
    */
    func makeDotView(){
        // Making dot animation for new item
        self.dot = RSDotsView(frame: CGRectMake(870, -30, 300, 300))
        self.dot.dotsColor = UIColor.yellowColor()
    }
    
    
    /**
    Showing the dot
    */
    func showDotView(){
        self.dot.hidden = false
    }
    
    
    /**
    Hiding the dot
    */
    func hideDotView(){
        self.dot.hidden = true
    }
    
    
    /**
    Function for getting the new dot for adding to view
    
    :returns: RSDotsView The dot for adding to the view
    */
    func getDotView() -> RSDotsView{
        return self.dot
    }
    
    
    /**
    Function for checking if the dot is animating or not
    
    :returns: Bool For indicating if dot is animating or not
    */
    func isAnimating() -> Bool{
        return self.dot.isAnimating()
    }
    
}