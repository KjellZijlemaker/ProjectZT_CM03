//
//  TimerManager.swift
//  PostDuif
//
//  Created by Kjell Zijlemaker on 25-04-15.
//  Copyright (c) 2015 Kjell Zijlemaker. All rights reserved.
//  Code reference: Stack Overflow
//
//  Manager for setting the desired times for making timers

import Foundation

class TimerManager {
    
    var _timerTable = [Int: NSTimer]()
    var _id: Int = 0
    
    /*! Schedule a timer and return an integer that represents id of the timer
    */
    func startTimer(target: AnyObject, selector: Selector, userInfo: AnyObject, interval: NSTimeInterval) -> Int {
        var timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: target, selector: selector, userInfo: userInfo, repeats: false)
        _id += 1
        _timerTable[_id] = timer
        return _id
    }
    
    /*! Stop a timer of an id
    */
    func stopTimer(id: Int) {
        if let timer = _timerTable[id] {
            if timer.valid {
                timer.invalidate()
            }
        }
    }
    
    /*! Returns timer instance of an id
    */
    func getTimer(id: Int) -> NSTimer? {
        return _timerTable[id]
    }
    
}