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
    var select: Bool = false
    var resize: Bool = false
}

class CanvasView: UIView {
    
// UTILS PART //
    var editMode : Bool = false;
    var circleArray: Array<Circle> = Array()
    var circle: Circle!
    
// PARAMS PART //
    var lineColor: UIColor!
    var lineColorSelect: UIColor!
    var lineWidth: CGFloat!
    var touchPoint: CGPoint!
    var crossSize: CGFloat!
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColor = UIColor.black
        lineColorSelect = UIColor.link
        lineWidth = 5
        crossSize = 5
    }
    
// DISPLAY PART //
    
    override public func draw(_ rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext()
        {
            // draw tangant
            displayTangant(ctx: ctx)
            
            // draw circle
            displayCircle(ctx: ctx)
            
            // draw move cross
            if (editMode) {displayCross(ctx: ctx)}
            
        }
    }
    
    func displayCircle(ctx: CGContext) {
        ctx.setLineWidth(lineWidth)
        if (!editMode) {
            ctx.setStrokeColor(lineColor.cgColor)
        }
        if (circle != nil) {
            ctx.addEllipse(in: CGRect(x: circle.center.x - circle.radius,
                                      y: circle.center.y - circle.radius,
                                      width: circle.radius * 2,
                                      height: circle.radius * 2))
        }
        circleArray.forEach { it in
            if (editMode) {
                ctx.setStrokeColor(it.resize ? lineColorSelect.cgColor : lineColor.cgColor)
            }
            ctx.addEllipse(in: CGRect(x: it.center.x - it.radius,
                                      y: it.center.y - it.radius,
                                      width: it.radius * 2,
                                      height: it.radius * 2))
            if (editMode) {ctx.strokePath()}
        }
        if (!editMode) {ctx.strokePath()}
    }
    
    func displayTangant(ctx: CGContext) {
        var store : Array<Int> = Array()
        ctx.setLineWidth((lineWidth - 1.5) > 1 ? lineWidth - 1.5 : 1)
        circleArray.forEach { it in
            if (circle != nil) {
                drawTangant(c1: it, c2: circle, ctx: ctx)
            }
            circleArray.forEach { it2 in
                if (it.id != it2.id && store.contains(it2.id)) {
                    drawTangant(c1: it, c2: it2, ctx: ctx)
                }
            }
            store.append(it.id)
        }
        ctx.strokePath()
    }
    
    func displayCross(ctx: CGContext) {
        ctx.setLineWidth((lineWidth - 2.5) > 1 ? lineWidth - 2.5 : 1)
        circleArray.forEach { it in
            displayLine(p1: CGPoint(x: it.center.x - crossSize, y: it.center.y),
                     p2: CGPoint(x: it.center.x + crossSize, y: it.center.y),
                     ctx: ctx, rounded: true, color: it.select ? lineColorSelect : lineColor)
            displayLine(p1: CGPoint(x: it.center.x, y: it.center.y - crossSize),
                     p2: CGPoint(x: it.center.x, y: it.center.y + crossSize),
                     ctx: ctx, rounded: true, color: it.select ? lineColorSelect : lineColor)
            ctx.strokePath()
        }
    }
    
    func displayLine(p1: CGPoint, p2: CGPoint, ctx: CGContext, rounded: Bool, color: UIColor) {
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineCap(rounded ? CGLineCap.round : CGLineCap.butt)
    }

// DRAW PART //
    
    func drawTangant(c1: Circle, c2: Circle, ctx: CGContext) {
        let tangant = drawTangant(x1: c1.center.x,
                                  y1: c1.center.y,
                                  r1: c1.radius,
                                  x2: c2.center.x,
                                  y2: c2.center.y,
                                  r2: c2.radius)
        displayLine(p1: tangant[0], p2: tangant[1], ctx: ctx, rounded: false, color: lineColor)
        displayLine(p1: tangant[2], p2: tangant[3], ctx: ctx, rounded: false, color: lineColor)
    }
    
    func drawTangant(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat)-> Array<CGPoint>  {
          if (r1 == r2) {
              return (calcTangantEqual(x1: x1, y1: y1, r1: r1, x2: x2, y2: y2, r2: r2))
          }
          
          let (sX, sY, sR, bX, bY, bR) = r2 > r1 ? (x1, y1, r1, x2, y2, r2) : (x2, y2, r2, x1, y1, r1)
          
          // objectif 1: get intersection point of the outer tangants
          let xP = (sX * bR - bX * sR) / (bR - sR)
          let yP = (sY * bR - bY * sR) / (bR - sR)
          
          // objectif 2: get Bigger Cirle Points
          let bCP = calcTangantPoint(xP: xP, yP: yP, x: bX, y: bY, r: bR)

          // objectif 3: get Smaller Cirle Points
          let sCP = calcTangantPoint(xP: xP, yP: yP, x: sX, y: sY, r: sR)

          return ([bCP[0], sCP[0], bCP[1], sCP[1]])
          
      }
    
// ACTION PART //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            touchPoint = touch?.location(in: self )
            if (editMode) {
                var edit = false
                var index = 0
                while index < circleArray.count {
                    let size = reciprocalPythagore(c1: touchPoint.x - circleArray[index].center.x, c2: touchPoint.y - circleArray[index].center.y)
                    if (size <= crossSize + 5) {
                        circleArray[index].select = true
                        edit = true
                    } else if (circleArray[index].select) {
                        circleArray[index].select = false
                        edit = true
                    }
                    if (size <=  circleArray[index].radius + 5 && size >= circleArray[index].radius  - 5) {
                        circleArray[index].resize = true
                        edit = true
                    } else if (circleArray[index].select) {
                        circleArray[index].resize = false
                        edit = true
                    }
                    index += 1
                }
                if (edit) {
                    self.setNeedsDisplay()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            let point = touch!.location(in: self)
            var edit = false
            if (editMode) {
                var index = 0
                while index < circleArray.count {
                    if (circleArray[index].select == true) {
                        circleArray[index].center = point
                        edit = true
                    }
                    if (circleArray[index].resize == true) {
                        let value = reciprocalPythagore(c1: point.x - circleArray[index].center.x, c2: point.y - circleArray[index].center.y)
                        circleArray[index].radius = value >= 10 ? value : 10
                        edit = true
                    }
                    index += 1
                }
            } else {
                let value = reciprocalPythagore(c1: point.x - touchPoint.x, c2: point.y - touchPoint.y)
                circle = Circle(id: -1, center: touchPoint, radius: value >= 10 ? value : 10)
                edit = true
            }
            if (edit) {
                self.setNeedsDisplay()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (editMode) {
            var edit = false
            var index = 0
            while index < circleArray.count {
                if (circleArray[index].resize == true) {
                    circleArray[index].resize = false
                    edit = true
                }
                index += 1
            }
            if (edit) {
                self.setNeedsDisplay()
            }
        } else if (circle != nil) {
            circleArray.append(Circle(id : circleArray.count > 0 ? circleArray.last!.id + 1 : 0 ,center: circle.center, radius: circle.radius))
            circle = nil
        }
    }
    
    func clearCanvas() {
        circle = nil
        circleArray.removeAll()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
    func toggleEditMode(mode : Bool) {
        editMode = mode
        self.setNeedsDisplay()
    }
    
// MATH PART //
    
    func reciprocalPythagore(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
    }
    
    func calcTangantPoint(xP: CGFloat, yP: CGFloat, x: CGFloat, y: CGFloat, r: CGFloat) -> Array<CGPoint> {
        // formula http://www.ambrsoft.com/TrigoCalc/Circles2/Circles2Tangent_.htm
        
        // objectif 1: distance between the intersection point of tangants and the center of the circle
        let dirX = xP - x
        let dirY = yP - y
        
        let rSquare = r * r
        let dirSquare = (dirX * dirX) + (dirY * dirY)
        
        // objectif 2: distance between the intersection point of tangants and circle tangant point (pythagore)
        let root = (dirSquare - rSquare).squareRoot()
        
        // objectif 3: get the 2 intersections points between tangants and the circle
        let xt1 = (((rSquare * dirX) + (r * dirY * root)) / (dirSquare)) + x
        let yt1 = (((rSquare * dirY) + (r * dirX * root)) / (dirSquare)) + y
        
        let xt2 = (((rSquare * dirX) - (r * dirY * root)) / (dirSquare)) + x
        let yt2 = (((rSquare * dirY) - (r * dirX * root)) / (dirSquare)) + y

        // objectif 4: check which pair create tangants
        let s = ((y - yt1) * (yP - yt1)) / ((xt1 - x) * (xt1 - xP))

        return (s == 1 ? ([CGPoint(x: xt1, y: yt1), CGPoint(x: xt2, y: yt2)]) : ([CGPoint(x: xt1, y: yt2), CGPoint(x: xt2, y: yt1)]))
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
    
}
