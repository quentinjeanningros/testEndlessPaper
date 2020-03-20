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
    
    var minSizeTouch: CGFloat = 16
    var minCircleSize: CGFloat = 20
    var diffCenterTouch: CGPoint!
    var lastTouch: CGPoint!
    
//MARK: INIT PART
    
    override func viewDidLoad() {
        self.view.clipsToBounds = true
        self.view.isMultipleTouchEnabled = false
        
        gearWheel.min = self.minCircleSize
        gearWheel.onValueChange = selectedCircleSizeChanged
    }
    
//MARK: TOUCH PART
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastTouch = touch.location(in: self.view)
            guard (!gearWheel.contains(point: lastTouch, tolerance: minSizeTouch + 5)) else { return }
            
            canvasView.selected = canvasView.getCircleUnder(under: lastTouch, tolerance: minSizeTouch)
            if let circle = canvasView.selectedCircle {
                diffCenterTouch = CGPoint(x: circle.center.x - lastTouch.x, y:  circle.center.y - lastTouch.y)
                toggleWheel(circle: circle)
            } else {
                toggleWheel()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard (canvasView.selectedCircle != nil && self.diffCenterTouch != nil) else { return }
        if let touch = touches.first {
            let point = touch.location(in: self.view)
            canvasView.selectedCircle!.center = CGPoint(x: point.x + self.diffCenterTouch.x, y: point.y + self.diffCenterTouch.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.diffCenterTouch = nil
    }
    
//MARK: ACTION PART
    
    @IBAction func clearCanvas(_ sender: Any) {
        //canvasView.selected = nil
        canvasView.clearCanvas()
        toggleWheel()
        TutorialLabel.isHidden = false
    }
    
    @IBAction func doubleTapped(_ sender: Any) {
        canvasView.selected = canvasView.newCircle(position: lastTouch, size: minCircleSize + 20)
        toggleWheel(circle: canvasView.selectedCircle)
        TutorialLabel.isHidden = true
    }
    
    private func toggleWheel(circle: Circle? = nil) {
        if (circle != nil) {
            gearWheel.isHidden = false
            radiusLabel.isHidden = false
            gearWheel.value = circle!.radius
        } else {
            gearWheel.isHidden = true
            radiusLabel.isHidden = true
        }
    }
    
    private func selectedCircleSizeChanged(size: CGFloat) {
        if (canvasView.selectedCircle != nil) {
            canvasView.selectedCircle!.radius = size
            radiusLabel.text = Double(round(10 * canvasView.selectedCircle!.radius) / 10).description
        }
    }
    
}

