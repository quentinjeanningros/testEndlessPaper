//
//  CanvasView.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

struct Circle {
    var path: UIBezierPath
    var center: CGPoint
    var radius: CGFloat
}

class CanvasView: UIView {
    
    var lineColor: UIColor!
    var lineWidth: CGFloat!
    var touchPoint: CGPoint!
    
    var circleArray: Array<Circle> = Array()
    
    var counter: Int = 1
    
    override func layoutSubviews() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColor = UIColor.black
        lineWidth = 5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            drawCircle(center: (touch?.location(in: self ))!)
            if (circleArray.count > 1) {
                circleArray.forEach { circle1 in
                    circleArray.forEach { circle2 in
                        if (circle2.path != circle1.path) {
                            drawTangant(x1: circle1.center.x, y1: circle1.center.y, r1: circle1.radius, x2: circle2.center.x, y2: circle2.center.y, r2: circle2.radius)
                        }
                    }
                }
            }
        }
    }
    
    func drawCircle(center: CGPoint) {
        let radius = CGFloat(20 + Int.random(in: 0..<40))
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        circleArray.append(Circle(path: circlePath, center: center, radius: radius))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath

        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
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
    
    func pythagore(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
    }
    
    func drawTangant(x1: CGFloat, y1: CGFloat, r1: CGFloat, x2: CGFloat, y2: CGFloat, r2: CGFloat) {
        // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
        var diffX = x2 - x1
        var diffY = y2 - y1
        var diffR = r2 - r1
        if (r2 < r1) {
            diffX = x1 - x2
            diffY = y1 - y2
            diffR = r1 - r2
        }
        // objectif 1: get apha = radii and beta
        //          1-1: beta
        let beta = asin(diffR / pythagore(c1: diffX, c2: diffY))
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
        
        drawLine(p1: CGPoint(x: xT1, y: yT1), p2: CGPoint(x: xT2, y: yT2))
    }
    
    func clearCanvas() {
        circleArray.forEach { circle in circle.path.removeAllPoints()}
        circleArray.removeAll()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
