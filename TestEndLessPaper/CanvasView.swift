//
//  CanvasView.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

func hypotnuse(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
}

class Circle {
    //property
    public var center: CGPoint
    public var radius: CGFloat
    public var select: Bool = false
    public var resize: Bool = false
    
    //display property
    private let crossSize: CGFloat
    private let color: UIColor
    private let colorSelect: UIColor
    private let strokeWidth: CGFloat

    init(center: CGPoint, radius: CGFloat, crossSize: CGFloat, color: UIColor, colorSelect: UIColor, strokeWidth: CGFloat) {
        self.center = center
        self.radius = radius
        self.crossSize = crossSize
        self.color = color
        self.colorSelect = colorSelect
        self.strokeWidth = strokeWidth
    }
    
// DRAW PART //
    
    public func draw(ctx: CGContext) {
        ctx.setLineWidth(self.strokeWidth)
        ctx.setStrokeColor(self.resize ? colorSelect.cgColor : color.cgColor)
        ctx.addEllipse(in: CGRect(x: self.center.x - self.radius,
                                  y: self.center.y - self.radius,
                                  width: self.radius * 2,
                                  height: self.radius * 2))
        ctx.strokePath()
    }
    
    public func drawCross(ctx: CGContext) {
        drawLine(p1: CGPoint(x: self.center.x - self.crossSize,
                            y: self.center.y),
                p2: CGPoint(x: self.center.x + self.crossSize,
                            y: self.center.y),
                ctx: ctx,
                width: self.strokeWidth - 2.5 > 1 ? self.strokeWidth - 2.5 : 1,
                rounded: true,
                color: self.select ? self.colorSelect : self.color)
        drawLine(p1: CGPoint(x: self.center.x,
                             y: self.center.y - self.crossSize),
                p2: CGPoint(x: self.center.x,
                            y: self.center.y + self.crossSize),
                ctx: ctx,
                width: self.strokeWidth - 2.5 > 1 ? self.strokeWidth - 2.5 : 1,
                rounded: true,
                color: self.select ? self.colorSelect : self.color)
        ctx.strokePath()
    }
    
    public func drawTangant(ctx: CGContext, circle: Circle?) {
        if (circle == nil) {
            return
        }
        let size = hypotnuse(c1: self.center.x - circle!.center.x,
                             c2: self.center.y - circle!.center.y)
        if (size + circle!.radius > self.radius &&
            size + self.radius > circle!.radius) {
            let tangant = computeTangents(x1: self.center.x,
                                          y1: self.center.y,
                                          r1: self.radius,
                                          x2: circle!.center.x,
                                          y2: circle!.center.y,
                                          r2: circle!.radius)
            drawLine(p1: tangant[0],
                     p2: tangant[1],
                     ctx: ctx,
                     width: self.strokeWidth - 1.5 > 1.5 ? self.strokeWidth - 1.5 : 1.5,
                     rounded: false,
                     color: self.color)
            drawLine(p1: tangant[2],
                     p2: tangant[3],
                     ctx: ctx,
                    width: self.strokeWidth - 1.5 > 1.5 ? self.strokeWidth - 1.5 : 1.5,
                    rounded: false,
                    color: self.color)
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
    
    private func computeTangents(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat)-> Array<CGPoint>  {
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
    
    private func calcTangantPoint(xP: CGFloat, yP: CGFloat, x: CGFloat, y: CGFloat, r: CGFloat) -> Array<CGPoint> {
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
    
    private func calcTangantEqual(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat) -> Array<CGPoint> {
        // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
        let (diffX, diffY, diffR) = ((x2 - x1), (y2 - y1), (r2 - r1))

        // objectif 1: get apha = radii and beta
        //          1-1: beta
        let beta = asin(diffR / hypotnuse(c1: diffX, c2: diffY))
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

class CanvasView: UIView {
    
// UTILS PART //
    var editMode : Bool = false;
    var circleArray: Array<Circle> = Array()
    var circle: UnsafeMutablePointer<Circle>!
    
// PARAMS PART //
    var lineColor: UIColor!
    var lineColorSelect: UIColor!
    var lineWidth: CGFloat!
    var touchPoint: CGPoint!
    var crossSize: CGFloat!
    var minCircleSize: CGFloat!
    var selected: UnsafeMutablePointer<Circle>!
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColor = UIColor.black
        lineColorSelect = UIColor.link
        lineWidth = 5
        crossSize = 5
        minCircleSize = 15
    }
    
// DISPLAY PART //
    
    override public func draw(_ rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext()
        {
            // draw tangant
            for i in 0...(circleArray.count > 0 ? circleArray.count - 1 : 0) {
                if (i - 1 >= 0) {
                    circleArray[i].drawTangant(ctx: ctx, circle: circleArray[i - 1])
                }
            }
            
            // draw circle
            circleArray.forEach { it in
                it.draw(ctx: ctx)
                if (editMode) {
                    it.drawCross(ctx: ctx)
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
                var index = 0
                while index < circleArray.count {
                    let size = hypotnuse(c1: touchPoint.x - circleArray[index].center.x, c2: touchPoint.y - circleArray[index].center.y)
                    if (size <= crossSize + 5) {
                        selected = UnsafeMutablePointer<Circle>(&circleArray) + index
                        circleArray[index].select = true
                        break
                    }
                    if (size <=  circleArray[index].radius + 5 && size >= circleArray[index].radius  - 5) {
                        selected = UnsafeMutablePointer<Circle>(&circleArray) + index
                        circleArray[index].resize = true
                        break
                    }
                    index += 1
                }
            } else {
                circleArray.append(Circle(center: touchPoint,
                                          radius: minCircleSize,
                                          crossSize: crossSize,
                                          color: lineColor,
                                          colorSelect: lineColorSelect,
                                          strokeWidth: lineWidth))
                circle = UnsafeMutablePointer<Circle>(&circleArray) + circleArray.count - 1
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            let point = touch!.location(in: self)
            if (editMode && selected != nil) {
                if (selected.pointee.select == true) {
                    selected.pointee.center = point
                }
                if (selected.pointee.resize == true) {
                    let value = hypotnuse(c1: point.x - selected.pointee.center.x, c2: point.y - selected.pointee.center.y)
                    selected.pointee.radius = value >= minCircleSize ? value : minCircleSize
                }
            } else if (editMode == false) {
                let value = hypotnuse(c1: point.x - touchPoint.x, c2: point.y - touchPoint.y)
                circle.pointee.radius = value >= minCircleSize ? value : minCircleSize
            }
            self.setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (editMode && selected != nil) {
            selected.pointee.select = false
            selected.pointee.resize = false
            selected = nil
            self.setNeedsDisplay()
        } else if (circle != nil) {
            circle = nil
        }
    }
    
    public func clearCanvas() {
        circle = nil
        circleArray.removeAll()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
    public func toggleEditMode(mode : Bool) {
        editMode = mode
        self.setNeedsDisplay()
    }
    
}
