//
//  CanvasView.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

class CanvasView: UIView {

// PARAMS PART //

    private var lineColor: UIColor = UIColor.black
    private var lineColorSelect: UIColor = UIColor.link
    private var lineWidth: CGFloat = 5
    
    public var circleArray: Array<Circle> = Array()
    public var selected: Circle!
    
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
        }
    }

    
// ACTION PART //
    
    public func getACircle(point: CGPoint, marge: CGFloat) -> Circle? {
        for it in circleArray {
            if (it.IsIn(point: point, marge: marge)) {
                return (it)
            }
        }
        return (nil)
    }
    
    public func moveCircle(circle: Circle, point: CGPoint, diffCenterTouch: CGPoint = CGPoint(x: 0, y: 0)) {
        circle.center = CGPoint(x: point.x + diffCenterTouch.x, y: point.y + diffCenterTouch.y)
        self.setNeedsDisplay()
    }
    
    public func setSelectedSize(size: CGFloat) {
        if (selected != nil) {
            selected!.radius = size
            self.setNeedsDisplay()
        }
    }
    
    public func newCircle(position: CGPoint, size: CGFloat) -> Circle? {
        let circle =  Circle(center: position, radius: size)
        self.circleArray.append(circle)
        return (circle)
    }

    public func clearCanvas() {
        self.circleArray.removeAll()
        self.setNeedsDisplay()
    }
    
    public func select(circle: Circle?) {
        self.selected = circle
        self.setNeedsDisplay()
    }
}
