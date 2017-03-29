//
//  FlightsTimeManager.swift
//  FligthsCodingTest
//
//  Created by jose humberto partida garduño on 3/29/17.
//  Copyright © 2017 jose humberto partida garduño. All rights reserved.
//

import Foundation

/// Describe the timer behaviour
protocol TimeManagerDelegate {
    /// when the time interval is reached call this
    func timeUp()
}

/// use to detect when the 10 minutes has already happend
class TimeManager{
    /// timeInterval in seconds
    let timeInterval:Int = 600
    /// timer to schedule
    var timer:Timer?
    /// delegate to respond when the time is up
    var delegate:TimeManagerDelegate?
    
    init() {
        
    }
    
    /// local timer func timeup it reachs the time interval
    @objc func timeup(){
        timer?.invalidate()
        if delegate != nil{
            delegate?.timeUp()
        }
    }
    
    /// start the timer if its invalidated or nil
    func starTimer()
    {
        if timer == nil || !(timer!.isValid){
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(timeup), userInfo: nil, repeats: false)
        }
    }
    
    /// invalidate the timer
    func stopTimer()
    {
        timer?.invalidate()
        timer = nil
    }
    
    
    
}
