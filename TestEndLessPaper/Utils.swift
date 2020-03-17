//
//  Utils.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 17/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit


func distance(c1: CGFloat, c2: CGFloat) -> CGFloat {
        return (c1 * c1 + c2 * c2).squareRoot()
}

func drawLine(p1: CGPoint, p2: CGPoint, ctx: CGContext, width: CGFloat, rounded: Bool, color: UIColor) {
    ctx.setLineWidth(width)
    ctx.move(to: p1)
    ctx.addLine(to: p2)
    ctx.setStrokeColor(color.cgColor)
    ctx.setLineCap(rounded ? CGLineCap.round : CGLineCap.butt)
}
