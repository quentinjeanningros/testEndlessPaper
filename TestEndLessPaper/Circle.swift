//
//  Circle.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 17/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

class Circle {
    //property
        public var center: CGPoint
        public var radius: CGFloat

        init(center: CGPoint, radius: CGFloat) {
            self.center = center
            self.radius = radius
        }
        
        func contains(point: CGPoint, tolerance: CGFloat) -> Bool {
            return distance(c1: point.x - self.center.x, c2: point.y - self.center.y) <= self.radius + tolerance / 2 + tolerance
        }
        
    // DRAW PART //
        
        public func draw(ctx: CGContext, color: UIColor, strokeWidth: CGFloat) {
            ctx.setLineWidth(strokeWidth)
            ctx.setStrokeColor(color.cgColor)
            ctx.addEllipse(in: CGRect(x: self.center.x - self.radius,
                                      y: self.center.y - self.radius,
                                      width: self.radius * 2,
                                      height: self.radius * 2))
            ctx.strokePath()
        }
        
        public func drawTangent(ctx: CGContext, circle: Circle?, color: UIColor, strokeWidth: CGFloat) {
            if (circle == nil) {
                return
            }
            let size = distance(c1: self.center.x - circle!.center.x,
                                 c2: self.center.y - circle!.center.y)
            if (size + circle!.radius > self.radius &&
                size + self.radius > circle!.radius) {
                let tangent = computeTangents(circle: circle!)
                drawLine(p1: tangent[0],
                         p2: tangent[1],
                         ctx: ctx,
                         width: strokeWidth,
                         rounded: false,
                         color: color)
                drawLine(p1: tangent[2],
                         p2: tangent[3],
                         ctx: ctx,
                         width: strokeWidth,
                         rounded: false,
                         color: color)
                ctx.strokePath()
            }
        }
        
    // CALCUL PART //
        
        private func computeTangents(circle: Circle) -> Array<CGPoint> {
            // formula https://en.wikipedia.org/wiki/Tangent_lines_to_circles
            let (bX, bY, bR, sX, sY, sR) = self.radius >= circle.radius ? (self.center.x, self.center.y, self.radius, circle.center.x, circle.center.y, circle.radius) : (circle.center.x, circle.center.y, circle.radius, self.center.x, self.center.y, self.radius)
            let (diffX, diffY, diffR) = ((bX - sX), (bY - sY), ( bR - sR))

            // objectif 1: get apha = radii and beta
            //          1-1: beta
            let beta = asin(diffR / distance(c1: diffX, c2: diffY))
            //          1-2: radii
            let radii = (atan(diffY / diffX))
            
            let angle = (bX - sX) > 0 ? [(CGFloat.pi / 2), (3 * CGFloat.pi / 2)] : [(3 * CGFloat.pi / 2), (CGFloat.pi / 2)]
            
            //          1-3: alpha
            let alpha = (-1 * radii) - beta
            let variableX = cos(angle[0] - alpha)
            let variableY = sin(angle[0] - alpha)
            
            let alphaBis = radii - beta
            let variableXBis = cos(angle[1] + alphaBis)
            let variableYBis = sin(angle[1] + alphaBis)
            
            // objectif 2: x and y of the tangent from circle1
            let xT1 = sX + sR * variableX
            let yT1 = sY + sR * variableY
            
            // objectif 3: x and y of the tangent from circle2
            let xT2 = bX + bR * variableX
            let yT2 = bY + bR * variableY
            
            // objectif 2: x and y of the other tangent from circle1
            let xT3 = sX + sR * variableXBis
            let yT3 = sY + sR * variableYBis
            
            // objectif 3: x and y of the other tangent from circle2
            let xT4 = bX + bR * variableXBis
            let yT4 = bY + bR * variableYBis
            
            
            return ([CGPoint(x: xT1, y: yT1), CGPoint(x: xT2, y: yT2), CGPoint(x: xT3, y: yT3), CGPoint(x: xT4, y: yT4)])
        }
}
