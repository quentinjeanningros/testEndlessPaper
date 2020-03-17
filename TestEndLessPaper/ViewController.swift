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
    @IBOutlet weak var SizeLabel: UILabel!
    
    var minSizeTouch: CGFloat!
    var minCircleSize: CGFloat!
    
    var diffCenterTouch: CGPoint!
    var lastTouch: CGPoint!
    
// INIT PART //
    
    override func viewDidLoad() {
        self.view.clipsToBounds = true
        self.view.isMultipleTouchEnabled = false
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        
        self.minSizeTouch = 16
        self.minCircleSize = self.minSizeTouch + 4
        gearWheel.communInit(callback: setSelectedCircleSize, increment: 5, min: self.minCircleSize, speed: 4)
    }
    
// TOUCH PART //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil) {
            lastTouch = touch!.location(in: self.view)
            canvasView.select(circle: canvasView.getACircle(point: lastTouch, marge: minSizeTouch))
            if (canvasView.selected != nil) {
                diffCenterTouch = CGPoint(x: canvasView.selected.center.x - lastTouch.x,
                                          y:  canvasView.selected.center.y - lastTouch.y)
                displayWheel(circle: canvasView.selected)
            } else {
                 hideWheel()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if (touch != nil && canvasView.selected != nil) {
            let point = touch!.location(in: self.view)
            canvasView.moveCircle(circle: canvasView.selected!,
                                  point: point,
                                  diffCenterTouch: self.diffCenterTouch)
        }
    }
    
    
// ACTION PART //
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.select(circle: nil)
        canvasView.clearCanvas()
        hideWheel()
    }
    
    @objc func doubleTapped() {
        canvasView.select(circle: canvasView.newCircle(position: lastTouch, size: minCircleSize + 20))
        displayWheel(circle: canvasView.selected)
    }
    
    private func displayWheel(circle: Circle!) {
        if (circle != nil) {
            gearWheel.isHidden = false
            gearWheel.setValue(value: circle.radius)
            SizeLabel.text = Double(round(10 * canvasView.selected.radius) / 10).description
            SizeLabel.isHidden = false
        }
    }
    
    private func hideWheel() {
        gearWheel.isHidden = true
        SizeLabel.isHidden = true
    }
    
    private func setSelectedCircleSize(size: CGFloat) {
        canvasView.setCircleSize(circle: canvasView.selected, size: size)
        SizeLabel.text = Double(round(10 * canvasView.selected.radius) / 10).description
    }
    
}

