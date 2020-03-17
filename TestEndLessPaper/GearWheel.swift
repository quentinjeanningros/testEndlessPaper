//
//  gearWheel.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 17/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

class GearWheel: UIView {
    
    typealias Callback = (CGFloat) -> ()
    
// UTILS PARAMS PART //

    public var value: CGFloat!
    private var increment: CGFloat!
    private var min: CGFloat!
    private var lastX: CGFloat!
    
    public var callback: Callback!

// UX PARAMS PART //
    
    private var speed: CGFloat!
    private var incrementDisplay: CGFloat!
    private var size: CGFloat!
    private var ready: Bool = false

// INIT PART //
    
    public func communInit(callback: @escaping Callback, increment: CGFloat, min: CGFloat, speed: CGFloat) {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false

        self.callback = callback
        self.increment = increment
        self.min = min
        self.speed = speed
        self.incrementDisplay = self.bounds.width * 3 / 100 // consider  1 incrementDisplay = 1 increment
        self.size = self.bounds.height * 40 / 100
    }

// TOUCH PART //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            self.lastX = touch!.location(in: self).x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            let newValue = (self.lastX - touch!.location(in: self).x) * speed / self.incrementDisplay + self.value
            self.value = newValue > min ? newValue : min
            lastX = touch!.location(in: self).x
            self.setNeedsDisplay()
            if (self.callback != nil) {
                self.callback(self.value)
            }
        }
    }
    
// DRAW PART //
    
    override func draw(_ rect: CGRect) {
        if (self.value == nil) {
            return
        }
        if let ctx = UIGraphicsGetCurrentContext()
        {
            let mid = self.bounds.width / 2
            let trunck = self.value.truncatingRemainder(dividingBy: self.increment)
            let start = (self.value - trunck - self.min) / self.increment
            var xStart = mid - (start * self.incrementDisplay) - (trunck / self.increment *  self.incrementDisplay)
            if (xStart > (self.bounds.width / 2)) {
                xStart = (self.bounds.width / 2 - xStart) - xStart
            }
            
            let step = self.increment * 5
            let trunckStep = self.value - self.value.truncatingRemainder(dividingBy: self.increment * 5)
            
            var incr = CGFloat(0)
            var x: CGFloat
            
            repeat {
                x = (incr * self.incrementDisplay) + xStart
                if (((incr * self.increment) + trunckStep).truncatingRemainder(dividingBy: step) == 0) {
                    drawLine(p1: CGPoint(x: x, y: self.bounds.height - self.size),
                             p2: CGPoint(x: x, y: self.bounds.height),
                             ctx: ctx, width: 1,
                             rounded: false,
                             color: UIColor.black)
                } else {
                    drawLine(p1: CGPoint(x: x, y: self.bounds.height - self.size),
                             p2: CGPoint(x: x, y: self.bounds.height),
                             ctx: ctx, width: 1,
                             rounded: false,
                             color: UIColor.lightGray)
                }
                ctx.strokePath()
                incr += 1
            }  while (x < self.bounds.width)
            drawCursor(ctx: ctx, middle: mid)
        }
    }
        
    private func drawCursor(ctx: CGContext, middle: CGFloat) {
        drawLine(p1: CGPoint(x: middle, y: 0),
                 p2: CGPoint(x: middle, y: self.bounds.height),
                 ctx: ctx,
                 width: 2,
                 rounded: false,
                 color: UIColor.link)
        ctx.strokePath()
    }
    
// ACTION PART //
    
    public func setValue(value : CGFloat) {
        self.value = value
        self.setNeedsDisplay()
    }
}
