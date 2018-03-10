//
//  CircleOfFifthsPickerViewDelegate.swift
//  ChordTransposer
//
//  Created by Michael Roy on 3/3/18.
//  Copyright © 2018 Quebecois Engineering. All rights reserved.
//

import UIKit

class CircleOfFifthsPickerViewDelegate: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: Static Data
    let CircleOfFifthsSharps: [String] = ["A", "A♯", "B", "C", "C♯", "D", "D♯", "E", "F", "F♯", "G"]
    let CircleOfFifthsFlats: [String]  = ["A", "B♭", "B", "C", "D♭", "D", "E♭", "E", "F", "G♭", "G"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.CircleOfFifthsSharps.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.CircleOfFifthsSharps[row]
    }
}
