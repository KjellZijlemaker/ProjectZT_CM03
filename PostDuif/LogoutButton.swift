//
//  LogoutButton.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 14-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class LogoutButton: UIButton{
    private var logoutButton: UIButton!
    
    // For drawing custom button
    override func drawRect(rect: CGRect) {
        
    }
    
    // Making the logout button
    func showLogoutButton() -> UIButton{
        let logoutButton   = UIButton.buttonWithType(UIButtonType.System) as UIButton
        
        logoutButton.frame = CGRectMake(20, 20, 130, 130)
        logoutButton.userInteractionEnabled = true
        
        
        return logoutButton
    }
    
    

    
}