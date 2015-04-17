//
//  MainCarouselView.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 16-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//

import Foundation

class MainCarouselView: iCarousel{
    var carousel: iCarousel!
    
    // For drawing custom view
    override func drawRect(rect: CGRect) {
        
    }
    
    func setCarouselBackgroundColor(backgroundColor: UIColor){
        self.carousel.backgroundColor = backgroundColor
    }
    
    func setCarouselContrast(contrast: String){
        //Set contrast here
    }
    
    func getCarousel() -> iCarousel{
        return self.carousel
    }
    
}