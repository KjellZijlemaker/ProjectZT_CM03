//
//  Notification.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class NotificationDot: UIView{
    private var dot: RSDotsView!
    
    // For drawing custom textField
    override func drawRect(rect: CGRect) {
        
    }
    
    func makeDotView(){
        // Making dot animation for new item
        self.dot = RSDotsView(frame: CGRectMake(870, -30, 300, 300))
        self.dot.dotsColor = UIColor.yellowColor()
    }
    
    func showDotView(){
        self.dot.hidden = false
    }
    
    func hideDotView(){
        self.dot.hidden = true
    }
    
    func getDotView() -> RSDotsView{
        return self.dot
    }
    
    func isAnimating() -> Bool{
        return self.dot.isAnimating()
    }
    
}