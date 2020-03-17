//
//  CanvasView.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

func distance(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
}

func drawLine(p1: CGPoint, p2: CGPoint, ctx: CGContext, width: CGFloat, rounded: Bool, color: UIColor) {
    ctx.setLineWidth(width)
    ctx.move(to: p1)
    ctx.addLine(to: p2)
    ctx.setStrokeColor(color.cgColor)
    ctx.setLineCap(rounded ? CGLineCap.round : CGLineCap.butt)
    
}

// douvle tap crée
// deplacement cercle selectionne
// molette resize cercle selectionné

class Circle {
    //property
    public var center: CGPoint
    public var radius: CGFloat

    init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }
    
    public func IsIn(point: CGPoint, marge: CGFloat) -> Bool {
        if (distance(c1: point.x - self.center.x, c2: point.y - self.center.y) <= self.radius + marge / 2 + marge){
            return true
        }
        return false
    }
    
// DRAW PART //
    
    public func draw(ctx: CGContext, color: UIColor, strokeWidth: CGFloat) {
        ctx.setLineWidth(strokeWidth)
        ctx.setStrokeColor(color.cgColor)
        ctx.addEllipse(in: CGRect(x: self.center.x - self.radius,
                                  y: self.center.y - self.radius,
                                  width: self.radius * 2,
                                  height: self.radius * 2))
        ctx.strokePath()
    }
    
    public func drawTangent(ctx: CGContext, circle: Circle?, color: UIColor, strokeWidth: CGFloat) {
        if (circle == nil) {
            return
        }
        let size = distance(c1: self.center.x - circle!.center.x,
                             c2: self.center.y - circle!.center.y)
        if (size + circle!.radius > self.radius &&
            size + self.radius > circle!.radius) {
            let tangent = computeTangents(circle: circle!)
            drawLine(p1: tangent[0],
                     p2: tangent[1],
                     ctx: ctx,
                     width: strokeWidth,
                     rounded: false,
                     color: color)
            drawLine(p1: tangent[2],
                     p2: tangent[3],
                     ctx: ctx,
                     width: strokeWidth,
                     rounded: false,
                     color: color)
            ctx.strokePath()
        }
    }
    
// CALCUL PART //
    
    private func computeTangents(circle: Circle) -> Array<CGPoint> {
        // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
        let (bX, bY, bR, sX, sY, sR) = self.radius >= circle.radius ? (self.center.x, self.center.y, self.radius, circle.center.x, circle.center.y, circle.radius) : (circle.center.x, circle.center.y, circle.radius, self.center.x, self.center.y, self.radius)
        let (diffX, diffY, diffR) = ((bX - sX), (bY - sY), ( bR - sR))

        // objectif 1: get apha = radii and beta
        //          1-1: beta
        let beta = asin(diffR / distance(c1: diffX, c2: diffY))
        //          1-2: radii
        let radii = (atan(diffY / diffX))
        
        let angle = (bX - sX) > 0 ? [(CGFloat.pi / 2), (3 * CGFloat.pi / 2)] : [(3 * CGFloat.pi / 2), (CGFloat.pi / 2)]
        
        //          1-3: alpha
        let alpha = (-1 * radii) - beta
        let variableX = cos(angle[0] - alpha)
        let variableY = sin(angle[0] - alpha)
        
        let alphaBis = radii - beta
        let variableXBis = cos(angle[1] + alphaBis)
        let variableYBis = sin(angle[1] + alphaBis)
        
        // objectif 2: x and y of the tangent from circle1
        let xT1 = sX + sR * variableX
        let yT1 = sY + sR * variableY
        
        // objectif 3: x and y of the tangent from circle2
        let xT2 = bX + bR * variableX
        let yT2 = bY + bR * variableY
        
        // objectif 2: x and y of the other tangent from circle1
        let xT3 = sX + sR * variableXBis
        let yT3 = sY + sR * variableYBis
        
        // objectif 3: x and y of the other tangent from circle2
        let xT4 = bX + bR * variableXBis
        let yT4 = bY + bR * variableYBis
        
        
        return ([CGPoint(x: xT1, y: yT1), CGPoint(x: xT2, y: yT2), CGPoint(x: xT3, y: yT3), CGPoint(x: xT4, y: yT4)])
    }
}

// WHEEL ALLOW GROW UP //

class gearWheel {
    public var value: Float!
    private let increment: Float!
    private let min: Float!
    private let width: CGFloat!
    private let height: CGFloat!
    private let position: CGPoint!
    private let incrementDisplay: CGFloat!

    init(value: Float, increment: Float, min: Float, width: CGFloat, height: CGFloat, position: CGPoint) {
        self.value = value
        self.increment = increment
        self.min = min
        self.width = width
        self.height = height
        self.position = position
        self.incrementDisplay = self.width * 3 / 100 // consider  1 incrementDisplay = 1 increment
    }
    
    public func draw(ctx: CGContext) {
        let size = self.position.y + (self.height * 50 / 100)
        let mid = self.position.x + (self.width / 2)
        let trunck = self.value.truncatingRemainder(dividingBy: self.increment)
        let adjustement = -1 * CGFloat(self.increment - trunck) * self.incrementDisplay / CGFloat(self.increment)  + mid
        let adjustementStep = CGFloat(self.value - (self.increment - trunck).truncatingRemainder(dividingBy: 1))

        var posX: CGFloat
        
        // draw wheel after middle
        var incr = CGFloat(0)
        repeat {
            posX = (self.incrementDisplay * incr) + adjustement
            if (Float(adjustementStep + incr).truncatingRemainder(dividingBy: 5) == 0) {
                drawLine(p1: CGPoint(x: posX, y: size),
                         p2: CGPoint(x: posX, y: self.position.y + self.height),
                         ctx: ctx, width: 2,
                         rounded: false,
                         color: UIColor.black)
            } else {
                drawLine(p1: CGPoint(x: posX, y: size),
                         p2: CGPoint(x: posX, y: self.position.y + self.height),
                         ctx: ctx, width: 1,
                         rounded: false,
                         color: UIColor.black)
            }
            ctx.strokePath()
            incr += 1
        } while (posX < width)
        
        
        // draw wheel befor middle
        incr = CGFloat(0)
        var incrF = Float(0)
        while (posX > 0 && self.value + incrF >= self.min) {
            posX = (self.incrementDisplay * incr) + adjustement

            if (Float(adjustementStep + incr).truncatingRemainder(dividingBy: 5) == 0) {
                drawLine(p1: CGPoint(x: posX, y: size),
                         p2: CGPoint(x: posX, y: self.position.y + self.height),
                         ctx: ctx, width: 2,
                         rounded: false,
                         color: UIColor.black)
            } else {
                drawLine(p1: CGPoint(x: posX, y: size),
                         p2: CGPoint(x: posX, y: self.position.y + self.height),
                         ctx: ctx, width: 1,
                         rounded: false,
                         color: UIColor.black)
            }
            ctx.strokePath()
            incr -= 1
            incrF -= 1
        }
        drawCursor(ctx: ctx, middle: mid)
    }
    
    private func drawCursor(ctx: CGContext, middle: CGFloat) {
        drawLine(p1: CGPoint(x: middle, y: self.position.y),
                 p2: CGPoint(x: middle, y: self.position.y + self.height),
                 ctx: ctx,
                 width: 2,
                 rounded: false,
                 color: UIColor.link)
        ctx.strokePath()
    }
    
}

// VIEW //

class CanvasView: UIView {
    
// UTILS PART //

    var circleArray: Array<Circle> = Array()
    var selected: Circle?
    var diffCenterTouch: (x : CGFloat, y: CGFloat)!
    var lastTouch: CGPoint!
    var wheel: gearWheel!
// PARAMS PART //

    var lineColor: UIColor!
    var lineColorSelect: UIColor!
    var lineWidth: CGFloat!
    var minCircleSize: CGFloat!
    var minSizeTouch: CGFloat!
    
// INIT //
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
        
        lineColor = UIColor.black
        lineColorSelect = UIColor.link
        lineWidth = 5
        minSizeTouch = 16
        minCircleSize = minSizeTouch + 4
        self.wheel = gearWheel(value: 28, increment: 5, min: Float(minCircleSize), width: self.bounds.width, height: 25, position: CGPoint(x: 0, y: self.bounds.height - 100))
    }
    
// DISPLAY PART //
    
    override public func draw(_ rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext()
        {
            if (circleArray.count > 0) {
                
                // draw tangent
                for i in 0...(circleArray.count - 1) {
                    if (i - 1 >= 0) {
                        circleArray[i].drawTangent(ctx: ctx, circle: circleArray[i - 1], color: UIColor.black, strokeWidth: lineWidth - 1.5)
                    }
                }
            
                // draw circle
                for it in circleArray {
                    it.draw(ctx: ctx, color: it === selected ? lineColorSelect : lineColor, strokeWidth: lineWidth)
                }
                
            }
            // draw wheel
            wheel.draw(ctx: ctx)
        }
    }
    
// TOUCH PART //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            lastTouch = touch!.location(in: self)
            if (selected == nil) {
                for it in circleArray {
                    if (it.IsIn(point: lastTouch, marge: minSizeTouch)) {
                        selected = it
                        diffCenterTouch = (x: it.center.x - lastTouch.x, y: it.center.y - lastTouch.y)
                        break
                    }
                }
            } else if (selected!.IsIn(point: lastTouch, marge: minSizeTouch) == false) {
                selected = nil
                self.setNeedsDisplay()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil && selected != nil) {
            let point = touch!.location(in: self)
            moveCircle(circle: selected!, point: point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    @objc func doubleTapped() {
        newCircle(position: lastTouch)
    }
    
// ACTION PART //
    
    private func moveCircle(circle: Circle, point: CGPoint) {
        circle.center = CGPoint(x: point.x + diffCenterTouch.x, y: point.y + diffCenterTouch.y)
        self.setNeedsDisplay()
    }
    
    private func recizeCircle(circle: Circle, point: CGPoint) {
        self.setNeedsDisplay()
    }
    
    public func clearCanvas() {
        selected = nil
        circleArray.removeAll()
        self.setNeedsDisplay()
    }
    
    public func newCircle(position: CGPoint) {
        selected = Circle(center: position, radius: minCircleSize)
        circleArray.append(selected!)
        self.setNeedsDisplay()
    }
}
