//
//  ViewController.swift
//  TestEndLessPaper
//
//  Created by Quentin Jeanningros on 02/03/2020.
//  Copyright © 2020 Quentin Jeanningros. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var gearWheel: GearWheel!
    @IBOutlet weak var radiusLabel: UILabel!
    
    var minSizeTouch: CGFloat!
    var minCircleSize: CGFloat!
    
    var diffCenterTouch: CGPoint!
    var lastTouch: CGPoint!
    
// INIT PART //
    
    override func viewDidLoad() {
        self.view.clipsToBounds = true
        self.view.isMultipleTouchEnabled = false
        
        self.minSizeTouch = 16
        self.minCircleSize = self.minSizeTouch + 4
        gearWheel.initArgs(increment: 5, min: self.minCircleSize, speed: 4)
        gearWheel.callback = selectedCircleSizeChanged
    }
    
// TOUCH PART //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastTouch = touch.location(in: self.view)
            canvasView.select(circle: canvasView.getCircle(point: lastTouch, tolerance: minSizeTouch))
            if let circle = canvasView.getSelectedCircle() {
                diffCenterTouch = CGPoint(x: circle.center.x - lastTouch.x,
                                          y:  circle.center.y - lastTouch.y)
                displayWheel(display: true, circle: circle)
            } else {
                displayWheel(display: false)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, let circle = canvasView.getSelectedCircle() {
            let point = touch.location(in: self.view)
            canvasView.moveCircle(circle: circle,
                                  point: point,
                                  diffCenterTouch: self.diffCenterTouch)
        }
    }
    
    
// ACTION PART //
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.select(circle: nil)
        canvasView.clearCanvas()
        displayWheel(display: false)
    }
    
    @IBAction func doubleTapped(_ sender: Any) {
        canvasView.select(circle: canvasView.newCircle(position: lastTouch, size: minCircleSize + 20))
        displayWheel(display: true, circle: canvasView.getSelectedCircle())
    }
    
    private func displayWheel(display: Bool ,circle: Circle? = nil) {
        if (!display) {
            gearWheel.isHidden = true
            radiusLabel.isHidden = true
        } else if (circle != nil) {
            gearWheel.isHidden = false
            radiusLabel.isHidden = false
            gearWheel.setValue(value: circle!.radius)
        }
    }
    
    private func selectedCircleSizeChanged(size: CGFloat) {
        if let circle = canvasView.getSelectedCircle() {
            canvasView.setCircleSize(circle: circle, size: size)
            radiusLabel.text = Double(round(10 * circle.radius) / 10).description
        }
    }
    
}

