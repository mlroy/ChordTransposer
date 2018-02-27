//
//  ViewController.swift
//  ChordTransposer
//
//  Created by Michael Roy on 2/26/18.
//  Copyright © 2018 Quebecois Engineering. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sharpsOrFlatsLabel: UILabel!
    @IBOutlet weak var sharpsOrFlatsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }

    @IBAction func sharpsOrFlatsToggled(_ sender: UISwitch) {
        if (sender.isOn) {
            sharpsOrFlatsLabel.text = "Sharp Keys"
        }
        else {
            sharpsOrFlatsLabel.text = "Flat Keys"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

