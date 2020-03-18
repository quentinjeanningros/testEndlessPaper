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

    private var value: CGFloat!
    private var increment: CGFloat!
    private var min: CGFloat!
    private var lastX: CGFloat!
    
    public var callback: Callback?
    
    private var speed: CGFloat!

// INIT PART //
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
    }
    
    public func initArgs(increment: CGFloat, min: CGFloat, speed: CGFloat) {
        self.increment = increment
        self.min = min
        self.speed = speed
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
            let incrementDisplay = self.bounds.width * 3 / 100 // consider  1 incrementDisplay = 1 increment
            let newValue = (self.lastX - touch!.location(in: self).x) * speed / incrementDisplay + self.value
            setValue(value: newValue > min ? newValue : min)
            lastX = touch!.location(in: self).x
            self.setNeedsDisplay()
        }
    }
    
    func contains(point: CGPoint, tolerance: CGFloat) -> Bool {
        return (point.x > self.frame.minX - tolerance && point.x < self.frame.maxX + tolerance &&
        point.y > self.frame.minY - tolerance && point.y < self.frame.maxY + tolerance)
    }
    
// DRAW PART //
    
    override func draw(_ rect: CGRect) {
        guard self.value != nil else { return }
        if let ctx = UIGraphicsGetCurrentContext()
        {
            let incrementDisplay = self.bounds.width * 3 / 100 // consider  1 incrementDisplay = 1 increment
            let gearHeight = self.bounds.height * 40 / 100
            let mid = self.bounds.width / 2
            let trunck = self.value.truncatingRemainder(dividingBy: self.increment)
            let start = (self.value - trunck - self.min) / self.increment
            var xStart = mid - (start * incrementDisplay) - (trunck / self.increment *  incrementDisplay)
            if (xStart > (self.bounds.width / 2)) {
                xStart = (self.bounds.width / 2 - xStart) - xStart
            }
            
            let step = self.increment * 5
            let trunckStep = self.value - self.value.truncatingRemainder(dividingBy: self.increment * 5)
            
            var incr = CGFloat(0)
            var x: CGFloat
            
            repeat {
                x = (incr * incrementDisplay) + xStart
                if (((incr * self.increment) + trunckStep).truncatingRemainder(dividingBy: step) == 0) {
                    drawLine(p1: CGPoint(x: x, y: self.bounds.height - gearHeight),
                             p2: CGPoint(x: x, y: self.bounds.height),
                             ctx: ctx, width: 1,
                             rounded: false,
                             color: UIColor.black)
                } else {
                    drawLine(p1: CGPoint(x: x, y: self.bounds.height - gearHeight),
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
        if (self.callback != nil) {
            self.callback!(value)
        }
        self.setNeedsDisplay()

    }
}
