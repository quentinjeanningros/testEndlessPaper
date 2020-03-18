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
    @IBOutlet weak var TutorialLabel: UILabel!
    
    var minSizeTouch: CGFloat!
    var minCircleSize: CGFloat!
    
    var diffCenterTouch: CGPoint!
    var lastTouch: CGPoint!
    
//MARK: INIT PART
    
    override func viewDidLoad() {
        self.view.clipsToBounds = true
        self.view.isMultipleTouchEnabled = false
        
        self.minSizeTouch = 16
        self.minCircleSize = self.minSizeTouch + 4
        gearWheel.initArgs(increment: 5, min: self.minCircleSize, speed: 4)
        gearWheel.actionUpdate = selectedCircleSizeChanged
    }
    
//MARK: TOUCH PART
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastTouch = touch.location(in: self.view)
            guard (!gearWheel.contains(point: lastTouch, tolerance: minSizeTouch + 5)) else { return }
            
            canvasView.selected = canvasView.getCircle(point: lastTouch, tolerance: minSizeTouch)
            if let circle = canvasView.selected {
                diffCenterTouch = CGPoint(x: circle.center.x - lastTouch.x, y:  circle.center.y - lastTouch.y)
                displayWheel(display: true, circle: circle)
            } else {
                displayWheel(display: false)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard (canvasView.selected != nil && self.diffCenterTouch != nil) else { return }
        if let touch = touches.first {
            let point = touch.location(in: self.view)
            canvasView.selectedCenter = CGPoint(x: point.x + self.diffCenterTouch.x, y: point.y + self.diffCenterTouch.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.diffCenterTouch = nil
    }
    
//MARK: ACTION PART
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.selected = nil
        canvasView.clearCanvas()
        displayWheel(display: false)
        TutorialLabel.isHidden = false
    }
    
    @IBAction func doubleTapped(_ sender: Any) {
        canvasView.selected = canvasView.newCircle(position: lastTouch, size: minCircleSize + 20)
        displayWheel(display: true, circle: canvasView.selected)
        TutorialLabel.isHidden = true
    }
    
    private func displayWheel(display: Bool ,circle: Circle? = nil) {
        if (!display) {
            gearWheel.isHidden = true
            radiusLabel.isHidden = true
        } else if (circle != nil) {
            gearWheel.isHidden = false
            radiusLabel.isHidden = false
            gearWheel.value = circle!.radius
        }
    }
    
    private func selectedCircleSizeChanged(size: CGFloat) {
        if let circle = canvasView.selected {
            canvasView.selectedRadius = size
            radiusLabel.text = Double(round(10 * circle.radius) / 10).description
        }
    }
    
}

