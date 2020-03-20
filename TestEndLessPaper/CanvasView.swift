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
    
    public var selected : Circle? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var selectedRadius : CGFloat? {
        get {
            guard (selected != nil) else {return nil}
            return self.selected!.radius
        }
        set {
            guard (selected != nil && newValue != nil) else { return }
            self.selected!.radius = newValue!
            self.setNeedsDisplay()
        }
    }
    
    public var selectedCenter : CGPoint? {
        get {
            if (selected != nil) {
                return self.selected!.center
            }
            return nil
        }
        set {
            guard let sel = selected, let newCenter = newValue  else { return }
            sel.center = newCenter
            self.setNeedsDisplay()
        }
    }
    
//MARK: DISPLAY PART
    
    override public func draw(_ rect: CGRect)
    {
        guard circleArray.count > 0 else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        for i in 1..<circleArray.count {
            circleArray[i].drawTangent(ctx: ctx,
                                       circle: circleArray[i - 1],
                                       color: UIColor.black,
                                       strokeWidth: lineWidth - 1.5)
        }
        // draw circle
        for it in circleArray {
            it.draw(ctx: ctx, color: it === selected ? lineColorSelect : lineColor, strokeWidth: lineWidth)
        }
    }

    
//MARK: ACTION PART
    
    public func getCircle(under: CGPoint, tolerance: CGFloat) -> Circle? {
        for it in circleArray {
            if (it.contains(point: under, tolerance: tolerance)) {
                return (it)
            }
        }
        return (nil)
    }
    
    public func newCircle(position: CGPoint, size: CGFloat) -> Circle? {
        let circle = Circle(center: position, radius: size)
        self.circleArray.append(circle)
        return (circle)
    }

    public func clearCanvas() {
        self.circleArray.removeAll()
        self.setNeedsDisplay()
    }
}
