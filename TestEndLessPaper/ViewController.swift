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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var EditSwitch: UISwitch!
    
    @IBAction func toggleEdit(_ sender: UISwitch) {
        canvasView.toggleEditMode(mode: sender.isOn)
    }
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
        EditSwitch.setOn(false, animated: true)
        canvasView.toggleEditMode(mode: false)
        
    }
    
}

