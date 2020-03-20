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
    
    private var circleArray = [Circle]()
    
    public var selected: Int = -1 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var selectedCircle : Circle? {
        get {
            guard (selected >= 0 && selected < circleArray.count) else { return nil}
            return circleArray[selected]
        }
        set {
            guard (selected >= 0 || selected < circleArray.count) else { return }
            circleArray[selected] = newValue!
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
        for (index, it) in circleArray.enumerated() {
            it.draw(ctx: ctx, color: selected == index ? lineColorSelect : lineColor, strokeWidth: lineWidth)
        }
    }

    
//MARK: ACTION PART
    
    public func getCircleUnder(under: CGPoint, tolerance: CGFloat) -> Int {
        for (index, it) in circleArray.enumerated() {
            if (it.contains(point: under, tolerance: tolerance)) {
                return (index)
            }
        }
        return (-1)
    }
    
    public func newCircle(position: CGPoint, size: CGFloat) -> Int {
        let circle = Circle(center: position, radius: size)
        let index = circleArray.count
        self.circleArray.append(circle)
        return (index)
    }

    public func clearCanvas() {
        self.circleArray.removeAll()
        self.setNeedsDisplay()
    }
}
