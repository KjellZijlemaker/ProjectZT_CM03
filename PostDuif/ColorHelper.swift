//
//  ColorHelper.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//
//  Helper class for colors.

import Foundation

class ColorHelper{
    
    /**
    Function for transforming colorcode to a color
    
    :param: colorCode Code to be transformed to color
    :param: alpha Always 1, can add opacity
    :returns: UIColor The transformed color
    */
    class func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        var scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0;
        scanner.scanHexInt(&color) // Scan the color
        
        // Make the color
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha)) // Return it
    }
    
}