//
//  gearWheel.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 17/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

@IBDesignable class GearWheel: UIView {
    
    typealias ActionUpdate = (CGFloat) -> ()
    
//MARK: UTILS PARAMS PART
    
    @IBInspectable var value: CGFloat = 5 {
        didSet {
            value = value > min ? value : min
            if (self.onValueChange != nil) {
                self.onValueChange!(value)
            }
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var min: CGFloat = 0 {
        didSet {
            guard value < min else { return }
            value = min
        }
    }
    @IBInspectable var increment: CGFloat = 5 {
        didSet {
            increment = increment > 0 ? increment : 1
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var step: CGFloat = 5 {
        didSet {
            step = step > 0 ? step : 1
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var speed: CGFloat = 4
    @IBInspectable var gearColor: UIColor = UIColor.lightGray
    @IBInspectable var stepColor: UIColor = UIColor.black
    @IBInspectable var cursorColor: UIColor = UIColor.link
    
    public var onValueChange: ActionUpdate?

    private var lastX: CGFloat = 0
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
//MARK: INIT PART
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }
    
    private func setView() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
    }

//MARK: TOUCH PART
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.lastX = touch.location(in: self).x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let incrementDisplay = self.bounds.width * 3 / 100 // consider  1 incrementDisplay = 1 increment
            let tmp = (self.lastX - touch.location(in: self).x) * speed / incrementDisplay + self.value
            let trunckValue = self.value.truncatingRemainder(dividingBy: self.increment)
            let trunckTmp = tmp.truncatingRemainder(dividingBy: self.increment)
            if ((self.value - trunckValue) / self.increment != (tmp - trunckTmp) / self.increment) {
                print("haptic feedback")
                self.generator.impactOccurred()
            }
            self.value = tmp
            // self.value  = (self.lastX - touch.location(in: self).x) * speed / incrementDisplay + self.value
            lastX = touch.location(in: self).x
        }
    }
    
    func contains(point: CGPoint, tolerance: CGFloat) -> Bool {
        return (point.x > self.frame.minX - tolerance && point.x < self.frame.maxX + tolerance &&
        point.y > self.frame.minY - tolerance && point.y < self.frame.maxY + tolerance)
    }
    
//MARK: DRAW PART
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let incrementDisplay = self.bounds.width * 3 / 100 // consider  1 incrementDisplay = 1 increment
        let gearHeight = self.bounds.height * 40 / 100
        let mid = self.bounds.width / 2
        let trunck = self.value.truncatingRemainder(dividingBy: self.increment)
        let start = (self.value - trunck - self.min) / self.increment
        var xStart = mid - (start * incrementDisplay) - (trunck / self.increment *  incrementDisplay)
        if (xStart > (self.bounds.width / 2)) {
            xStart = (self.bounds.width / 2 - xStart) - xStart
        }
        
        let displayStep = self.increment * self.step
        let trunckStep = self.value - self.value.truncatingRemainder(dividingBy: displayStep)
        
        var incr = CGFloat(0)
        var x: CGFloat
        
        repeat {
            x = (incr * incrementDisplay) + xStart
            if (((incr * self.increment) + trunckStep).truncatingRemainder(dividingBy: displayStep) == 0) {
                drawLine(p1: CGPoint(x: x, y: self.bounds.height - gearHeight),
                         p2: CGPoint(x: x, y: self.bounds.height),
                         ctx: ctx, width: 1,
                         rounded: false,
                         color: stepColor)
            } else {
                drawLine(p1: CGPoint(x: x, y: self.bounds.height - gearHeight),
                         p2: CGPoint(x: x, y: self.bounds.height),
                         ctx: ctx, width: 1,
                         rounded: false,
                         color: gearColor)
            }
            ctx.strokePath()
            incr += 1
        }  while (x < self.bounds.width)
        drawCursor(ctx: ctx, middle: mid)
    }
        
    private func drawCursor(ctx: CGContext, middle: CGFloat) {
        drawLine(p1: CGPoint(x: middle, y: 0),
                 p2: CGPoint(x: middle, y: self.bounds.height),
                 ctx: ctx,
                 width: 2,
                 rounded: false,
                 color: cursorColor)
        ctx.strokePath()
    }
}
