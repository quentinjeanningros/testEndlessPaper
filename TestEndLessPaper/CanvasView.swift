//
//  CanvasView.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

struct Circle {
    var id : Int
    var center: CGPoint
    var radius: CGFloat
}

class CanvasView: UIView {
    
    var lineColor: UIColor!
    var lineWidth: CGFloat!
    var touchPoint: CGPoint!
    var circleArray: Array<Circle> = Array()
    var circle: Circle!
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColor = UIColor.black
        lineWidth = 5
    }
    
    override public func draw(_ rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext()
        {
            ctx.setStrokeColor(lineColor.cgColor)
 
            // draw circle
            ctx.setLineWidth(lineWidth)
            
            if (circle != nil) {
                ctx.addEllipse(in: CGRect(x: circle.center.x - circle.radius,
                                          y: circle.center.y - circle.radius,
                                          width: circle.radius * 2,
                                          height: circle.radius * 2))
            }
            circleArray.forEach { it in
                ctx.addEllipse(in: CGRect(x: it.center.x - it.radius,
                                          y: it.center.y - it.radius,
                                          width: it.radius * 2,
                                          height: it.radius * 2))
            }
            var store : Array<Int> = Array()
            circleArray.forEach { it in
                drawTangant(c1: it, c2: circle, ctx: ctx)
                circleArray.forEach { it2 in
                    if (it.id != it2.id && store.contains(it2.id)) {
                        drawTangant(c1: it, c2: it2, ctx: ctx)
                    }
                }
                store.append(it.id)
            }
            ctx.strokePath()
        }
    }

    func drawTangant(c1: Circle, c2: Circle, ctx: CGContext) {
        let tangant = drawTangant(x1: c1.center.x,
                                  y1: c1.center.y,
                                  r1: c1.radius,
                                  x2: c2.center.x,
                                  y2: c2.center.y,
                                  r2: c2.radius)
        drawLine(p1: tangant[0], p2: tangant[1], ctx: ctx)
        drawLine(p1: tangant[2], p2: tangant[3], ctx: ctx)
    }
    
    func drawLine(p1: CGPoint, p2: CGPoint, ctx: CGContext) {
        ctx.move(to: p1)
        ctx.addLine(to: p2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            touchPoint = touch?.location(in: self )
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            let point = touch!.location(in: self)
            let x = point.x - touchPoint.x
            let y = point.y - touchPoint.y
            let value = reciprocalPythagore(c1: x, c2: y)
            circle = Circle(id: -1, center: touchPoint, radius: value >= 10 ? value : 10)
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (circle != nil) {
            circleArray.append(Circle(id : circleArray.count > 0 ? circleArray.last!.id + 1 : 0 ,center: circle.center, radius: circle.radius))
        }
    }
    
    func reciprocalPythagore(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
    }
    
    func drawTangant(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat)-> Array<CGPoint>  {
        if (r1 == r2) {
            return (calcTangantEqual(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2))
        }
        let (sX, sY, sR, bX, bY, bR) = r2 > r1 ? (x1, y1, r1, x2, y2, r2) : (x2, y2, r2, x1, y1, r1)

        // objectif 1: get intersection points of the outer tangants
        let xP = (sX * bR - bX * sR) / (bR - sR)
        let yP = (sY * bR - bY * sR) / (bR - sR)
        
        // objectif 2: get tangant point of circle2
        let s2 = calcTangantPoint(xP: xP, yP: yP, x: bX, y: bY, r: bR)

        // objectif 3: get tangant point of circle1
        let s1 = calcTangantPoint(xP: xP, yP: yP, x: sX, y: sY, r: sR)
        
        // objectif 4: get intersection points of the outer tangants 2
        let xP2 = (bX * sR - sX * bR) / (sR - bR)
        let yP2 = (bY * sR - sY * bR) / (sR - bR)
        
        // objectif 5: get tangant 2 point of circle2
        let s3 = calcTangantPoint(xP: xP2, yP: yP2, x: sX, y: sY, r: sR)

        // objectif 6: get tangant 2 point of circle1
        let s4 = calcTangantPoint(xP: xP2, yP: yP2, x: bX, y: bY, r: bR)

        return ([s1, s2, s3, s4])
        
    }
    
    func calcTangantPoint(xP: CGFloat, yP: CGFloat, x: CGFloat, y: CGFloat, r: CGFloat) -> CGPoint {
        let dirX = xP - x
        let dirY = yP - y
        let rSquare = r * r
        let dirSquare = (dirX * dirX) + (dirY * dirY)
        let root = (dirSquare - rSquare).squareRoot()
        
        let xt = (((rSquare * dirX) + (r * dirY * root)) / (dirSquare)) + x
        var yt = (((rSquare * dirY) - (r * dirX * root)) / (dirSquare)) + y
        let s = ((y - yt) * (yP - yt)) / ((xt - x) * (xt - xP))
        let round = ((1000 * s)/1000).rounded()
        
        print("/////////")
        print(round)
        if (s != -1 || s != 1) {
            yt = (((rSquare * dirY) + (r * dirX * root)) / (dirSquare)) + y
            let s2 = ((y - yt) * (yP - yt)) / ((xt - x) * (xt - xP))
            let round = ((1000 * s2)/1000).rounded()
            print(round)
        }
        return (CGPoint(x: xt, y: yt))
    }
    
    func calcTangantEqual(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat) -> Array<CGPoint> {
        // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
        let (diffX, diffY, diffR) = ((x2 - x1), (y2 - y1), (r2 - r1))

        // objectif 1: get apha = radii and beta
        //          1-1: beta
        let beta = asin(diffR / reciprocalPythagore(c1: diffX, c2: diffY))
        //          1-2: radii
        let radii =  -1 * (atan(diffY / diffX))
        //          1-3: alpha
        let alpha = radii - beta
        
        // objectif 2: x and y of the tangent from circle1
        let xT1 = x1 + r1 * cos((CGFloat.pi / 2) - alpha)
        let yT1 = y1 + r1 * sin((CGFloat.pi / 2) - alpha)
        
        // objectif 3: x and y of the tangent from circle2
        let xT2 = x2 + r2 * cos((CGFloat.pi / 2) - alpha)
        let yT2 = y2 + r2 * sin((CGFloat.pi / 2) - alpha)
        
        // objectif 4: x and y of the second tangent from circle1
        let xT4 = x1 + r1 * cos(((3 * CGFloat.pi) / 2) - alpha)
        let yT4 = y1 + r1 * sin(((3 * CGFloat.pi) / 2) - alpha)
        
        // objectif 5: x and y of the second tangent from circle2
        let xT5 = x2 + r2 * cos(((3 * CGFloat.pi) / 2) - alpha)
        let yT5 = y2 + r2 * sin(((3 * CGFloat.pi) / 2) - alpha)
        
        return ([CGPoint(x: xT1, y: yT1), CGPoint(x: xT2, y: yT2), CGPoint(x: xT4, y: yT4), CGPoint(x: xT5, y: yT5)])
    }
    
    func clearCanvas() {
        circle = nil
        circleArray.removeAll()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
}
