//
//  CanvasView.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

class CanvasView: UIView {

//MARK: PARAMS PART

    private var lineColor: UIColor = UIColor.black
    private var lineColorSelect: UIColor = UIColor.link
    private var lineWidth: CGFloat = 5
    
    private var circleArray: Array<Circle> = Array()
    private var selected: Circle!
    
//MARK: DISPLAY PART
    
    override public func draw(_ rect: CGRect)
    {
        guard circleArray.count > 0 else { return }
        if let ctx = UIGraphicsGetCurrentContext()
        {
            for i in 1..<circleArray.count {
                circleArray[i].drawTangent(ctx: ctx, circle: circleArray[i - 1], color: UIColor.black, strokeWidth: lineWidth - 1.5)
            }
            // draw circle
            for it in circleArray {
                it.draw(ctx: ctx, color: it === selected ? lineColorSelect : lineColor, strokeWidth: lineWidth)
            }
        }
    }

    
//MARK: ACTION PART
    
    public func getCircle(point: CGPoint, tolerance: CGFloat) -> Circle? {
        for it in circleArray {
            if (it.contains(point: point, tolerance: tolerance)) {
                return (it)
            }
        }
        return (nil)
    }
    
    public func moveCircle(circle: Circle, point: CGPoint, diffCenterTouch: CGPoint = CGPoint(x: 0, y: 0)) {
        circle.center = CGPoint(x: point.x + diffCenterTouch.x, y: point.y + diffCenterTouch.y)
        self.setNeedsDisplay()
    }
    
    public func setCircleSize(circle: Circle!, size: CGFloat) {
        if (circle != nil) {
            circle.radius = size
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
    
    public func getSelectedCircle() -> Circle? {
        return (self.selected)
    }
}
