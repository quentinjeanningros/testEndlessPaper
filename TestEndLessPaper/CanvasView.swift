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

// same angle car angle aparallele

class Circle {
    //property
    public var center: CGPoint
    public var radius: CGFloat
    
    //display property
    private let crossSize: CGFloat
    private let strokeWidth: CGFloat

    init(center: CGPoint, radius: CGFloat, crossSize: CGFloat, strokeWidth: CGFloat = 1) {
        self.center = center
        self.radius = radius
        self.crossSize = crossSize
        self.strokeWidth = strokeWidth
    }
    
// DRAW PART //
    
    public func draw(ctx: CGContext, color: UIColor) {
        ctx.setLineWidth(self.strokeWidth)
        ctx.setStrokeColor(color.cgColor)
        ctx.addEllipse(in: CGRect(x: self.center.x - self.radius,
                                  y: self.center.y - self.radius,
                                  width: self.radius * 2,
                                  height: self.radius * 2))
        ctx.strokePath()
    }
    
    public func drawCross(ctx: CGContext, color: UIColor) {
        drawLine(p1: CGPoint(x: self.center.x - self.crossSize,
                            y: self.center.y),
                p2: CGPoint(x: self.center.x + self.crossSize,
                            y: self.center.y),
                ctx: ctx,
                width: self.strokeWidth - 2.5 > 1 ? self.strokeWidth - 2.5 : 1,
                rounded: true,
                color: color)
        drawLine(p1: CGPoint(x: self.center.x,
                             y: self.center.y - self.crossSize),
                p2: CGPoint(x: self.center.x,
                            y: self.center.y + self.crossSize),
                ctx: ctx,
                width: self.strokeWidth - 2.5 > 1 ? self.strokeWidth - 2.5 : 1,
                rounded: true,
                color: color)
        ctx.strokePath()
    }
    
    public func drawTangent(ctx: CGContext, circle: Circle?, color: UIColor) {
        if (circle == nil) {
            return
        }
        let size = distance(c1: self.center.x - circle!.center.x,
                             c2: self.center.y - circle!.center.y)
        if (size + circle!.radius > self.radius &&
            size + self.radius > circle!.radius) {
            let tangent = computeTangents(x1: self.center.x,
                                          y1: self.center.y,
                                          r1: self.radius,
                                          x2: circle!.center.x,
                                          y2: circle!.center.y,
                                          r2: circle!.radius)
            drawLine(p1: tangent[0],
                     p2: tangent[1],
                     ctx: ctx,
                     width: self.strokeWidth - 1.5 > 1.5 ? self.strokeWidth - 1.5 : 1.5,
                     rounded: false,
                     color: color)
            drawLine(p1: tangent[2],
                     p2: tangent[3],
                     ctx: ctx,
                    width: self.strokeWidth - 1.5 > 1.5 ? self.strokeWidth - 1.5 : 1.5,
                    rounded: false,
                    color: color)
            ctx.strokePath()
        }
    }
    
    private func drawLine(p1: CGPoint, p2: CGPoint, ctx: CGContext, width: CGFloat, rounded: Bool, color: UIColor) {
        ctx.setLineWidth(width)
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineCap(rounded ? CGLineCap.round : CGLineCap.butt)
    }
    
// CALCUL PART //
    
//    private func computeTangents(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat)-> Array<CGPoint>  {
//        if (r1 == r2) {
//            return (computetangentEqual(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2))
//        }
//
//        let (sX, sY, sR, bX, bY, bR) = r2 > r1 ? (x1, y1, r1, x2, y2, r2) : (x2, y2, r2, x1, y1, r1)
//
//        // objectif 1: get intersection point of the outer tangents
//        let xP = (sX * bR - bX * sR) / (bR - sR)
//        let yP = (sY * bR - bY * sR) / (bR - sR)
//
//        // objectif 2: get Bigger Cirle Points
//        let bCP = calctangentPoint(xP: xP, yP: yP, x: bX, y: bY, r: bR)
//
//        // objectif 3: get Smaller Cirle Points
//        let sCP = calctangentPoint(xP: xP, yP: yP, x: sX, y: sY, r: sR)
//
//        return ([bCP[0], sCP[0], bCP[1], sCP[1]])
//    }
//
//    private func calctangentPoint(xP: CGFloat, yP: CGFloat, x: CGFloat, y: CGFloat, r: CGFloat) -> Array<CGPoint> {
//        // formula http://www.ambrsoft.com/TrigoCalc/Circles2/Circles2Tangent_.htm
//
//        // objectif 1: distance between the intersection point of tangents and the center of the circle
//        let dirX = xP - x
//        let dirY = yP - y
//
//        let rSquare = r * r
//        let dirSquare = (dirX * dirX) + (dirY * dirY)
//
//        // objectif 2: distance between the intersection point of tangents and circle tangent point (pythagore)
//        let root = (dirSquare - rSquare).squareRoot()
//
//        // objectif 3: get the 2 intersections points between tangents and the circle
//        let xt1 = (((rSquare * dirX) + (r * dirY * root)) / (dirSquare)) + x
//        let yt1 = (((rSquare * dirY) + (r * dirX * root)) / (dirSquare)) + y
//
//        let xt2 = (((rSquare * dirX) - (r * dirY * root)) / (dirSquare)) + x
//        let yt2 = (((rSquare * dirY) - (r * dirX * root)) / (dirSquare)) + y
//
//        // objectif 4: check which pair create tangents
//        let s = ((y - yt1) * (yP - yt1)) / ((xt1 - x) * (xt1 - xP))
//
//        return (s == 1 ? ([CGPoint(x: xt1, y: yt1), CGPoint(x: xt2, y: yt2)]) : ([CGPoint(x: xt1, y: yt2), CGPoint(x: xt2, y: yt1)]))
//    }
    
    private func computeTangents(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat) -> Array<CGPoint> {
        // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
        let (bX, bY, bR, sX, sY, sR) = r1 >= r2 ? (x1, y1, r1, x2, y2, r2) : (x2, y2, r2, x1, y1, r1)
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

class CanvasView: UIView {
    
// UTILS PART //
    var editMode : Bool = false;
    var circleArray: Array<Circle> = Array()
    var selected: (id: Int, circle: Circle?) = (-1, nil)
    var resized: (id: Int, circle: Circle?) = (-1, nil)
    
// PARAMS PART //
    var lineColor: UIColor!
    var lineColorSelect: UIColor!
    var lineWidth: CGFloat!
    var touchPoint: CGPoint!
    var crossSize: CGFloat!
    var minCircleSize: CGFloat!
    var minSizeTouch: CGFloat!
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColor = UIColor.black
        lineColorSelect = UIColor.link
        lineWidth = 5
        crossSize = 5
        minSizeTouch = 16
        minCircleSize = minSizeTouch + 10
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
                        circleArray[i].drawTangent(ctx: ctx, circle: circleArray[i - 1], color: UIColor.black)
                    }
                }
            
                // draw circle
                for i in 0...(circleArray.count - 1) {
                    circleArray[i].draw(ctx: ctx, color: i == resized.id ? lineColorSelect : lineColor)
                    if (editMode) {
                        circleArray[i].drawCross(ctx: ctx, color: i == selected.id ? lineColorSelect : lineColor)
                    }
                }
            }
        }
    }
    
// ACTION PART //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            touchPoint = touch?.location(in: self )
            if (editMode) {
                for i in 0...(circleArray.count > 0 ? circleArray.count - 1 : 0) {
                    let size = distance(c1: touchPoint.x - circleArray[i].center.x, c2: touchPoint.y - circleArray[i].center.y)
                    if (size <= crossSize + minSizeTouch) {
                        selected = (id: i, circle: circleArray[i])
                        break
                    }
                    if (size <= circleArray[i].radius + minSizeTouch / 2 && size >= circleArray[i].radius - minSizeTouch / 2) {
                        resized = (id: i, circle: circleArray[i])
                        break
                    }
                }
            } else {
                resized = (id: circleArray.count, circle: Circle(center: touchPoint,
                                                                     radius: minCircleSize,
                                                                     crossSize: crossSize,
                                                                     strokeWidth: lineWidth))
                circleArray.append(resized.circle!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            let point = touch!.location(in: self)
            if (editMode && (selected.id != -1 || resized.id != -1)) {
                if (selected.id != -1) {
                    selected.circle!.center = point
                }
                if (resized.id != -1) {
                    let value = distance(c1: point.x - resized.circle!.center.x, c2: point.y - resized.circle!.center.y)
                    resized.circle!.radius = value >= minCircleSize ? value : minCircleSize
                }
                self.setNeedsDisplay()
            }
            else if (editMode == false && resized.id != -1) {
                let value = distance(c1: point.x - touchPoint.x, c2: point.y - touchPoint.y)
                resized.circle!.radius = value >= minCircleSize ? value : minCircleSize
                self.setNeedsDisplay()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (editMode && selected.id != -1) {
            selected = (id: -1, circle: nil)
            resized = (id: -1, circle: nil)
            self.setNeedsDisplay()
        } else if (resized.id != -1) {
            resized = (id: -1, circle: nil)
            self.setNeedsDisplay()
        }
    }
    
    public func clearCanvas() {
        circleArray.removeAll()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
    public func toggleEditMode(mode : Bool) {
        editMode = mode
        self.setNeedsDisplay()
    }
    
}
