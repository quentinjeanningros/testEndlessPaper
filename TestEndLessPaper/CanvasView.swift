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
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            touchPoint = touch?.location(in: self )
        }
    }
    
    override public func draw(_ rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext()
        {
            ctx.setLineWidth(lineWidth)
            ctx.setStrokeColor(lineColor.cgColor)
            if (circle != nil) {
                ctx.addEllipse(in: CGRect(x: circle.center.x, y: circle.center.y ,width: circle.radius, height: circle.radius))
            }
            circleArray.forEach { it in
                ctx.addEllipse(in: CGRect(x: it.center.x, y: it.center.y ,width: it.radius, height: it.radius))
                drawTangant(x1: circle.center.x, y1: circle.center.y, r1: circle.radius, x2: it.center.x, y2: it.center.y, r2: it.radius)
                circleArray.forEach { it2 in
                    ctx.addEllipse(in: CGRect(x: it.center.x, y: it.center.y ,width: it.radius, height: it.radius))
                    drawTangant(x1: circle.center.x, y1: circle.center.y, r1: circle.radius, x2: it.center.x, y2: it.center.y, r2: it.radius)
                    
                }
            }
            ctx.strokePath()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            let point = touch!.location(in: self)
            let x = point.x - touchPoint.x
            let y = point.y - touchPoint.y
            let size = ((x * x) + (y * y)).squareRoot();
            circle = Circle(id: -1, center: touchPoint, radius: size)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(circle.center)
        print(circle.radius)
        if (circle != nil) {
            circleArray.append(Circle(id : circleArray.count > 0 ? circleArray.last!.id + 1 : 0 ,center: circle.center, radius: circle.radius))
        }
    }
    
    
    func drawLine(p1: CGPoint, p2: CGPoint) {
        let line = UIBezierPath()
        line.move(to: p1)
        line.addLine(to: p2)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = line.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        if (lineWidth - 2 > 0) {
            shapeLayer.lineWidth = lineWidth - 2
        } else {
            shapeLayer.lineWidth = 1
        }
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
    }
    
    func reciprocalPythagore(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
    }
    
    func drawTangant(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat) {
        // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
        let (diffX, diffY, diffR) = r2 < r1 ? ((x1 - x2), (y1 - y2), (r1 - r2)) : ((x2 - x1), (y2 - y1), (r2 - r1))

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
        
        drawLine(p1: CGPoint(x: xT1, y: yT1), p2: CGPoint(x: xT2, y: yT2))
        drawLine(p1: CGPoint(x: xT4, y: yT4), p2: CGPoint(x: xT5, y: yT5))
    }
    
    func clearCanvas() {
        circleArray.removeAll()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
}
