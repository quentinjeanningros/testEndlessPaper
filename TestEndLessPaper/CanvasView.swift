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
    
    private var _selected: Circle?
    
    public var selected : Circle? {
        get {
            return self._selected
        }
        set {
            self._selected = newValue
            self.setNeedsDisplay()
        }
    }
    
    public var selectedRadius : CGFloat {
        get {
            guard (_selected != nil) else {return CGFloat.nan}
            return self._selected!.radius
        }
        set {
            guard (_selected != nil) else { return }
            self._selected!.radius = newValue
            self.setNeedsDisplay()
        }
    }
    
    public var selectedCenter : CGPoint? {
        get {
            if (_selected != nil) {
                return self._selected!.center
            }
            return nil
        }
        set {
            guard (_selected != nil && newValue != nil) else { return }
            self._selected!.center = newValue!
            self.setNeedsDisplay()
        }
    }
    
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
                it.draw(ctx: ctx, color: it === _selected ? lineColorSelect : lineColor, strokeWidth: lineWidth)
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
