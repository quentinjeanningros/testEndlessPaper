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
        // Do any additional setup after loading the view.
    }

    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.clearCanvas()
    }
    
}

