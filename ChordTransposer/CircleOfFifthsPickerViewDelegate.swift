//
//  CircleOfFifthsPickerViewDelegate.swift
//  ChordTransposer
//
//  Created by Michael Roy on 3/3/18.
//  Copyright © 2018 Quebecois Engineering. All rights reserved.
//

import UIKit
import os.log


class CircleOfFifthsPickerViewDelegate: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Object data
    var sharpsOrFlats :Bool = true
    
    // MARK: Static Data
    let circleOfFifthsSharps: [String] = ["A", "A♯", "B", "C", "C♯", "D", "D♯", "E", "F", "F♯", "G"]
    let circleOfFifthsFlats: [String]  = ["A", "B♭", "B", "C", "D♭", "D", "E♭", "E", "F", "G♭", "G"]
  
    // majorKeySteps is an array of the number of half-steps between the current
    // chord and the next chord in the key.
    // Major Key chord structure:  I ii iii IV V vi viidim I
    let majorKeySteps: [Int] = [2, 2, 1, 2, 2, 2]
    // Minor Key chord structure:  i ii(dim) III iv v VI VII
    let minorKeySteps: [Int] = [2, 1, 2, 2, 1, 2]

    // MARK: CircleOfFifthsPickerDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.circleOfFifthsSharps.count
    }
    
    // MARK: CircleOfFifthsPickerViewDelegate methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.circleOfFifthsSharps[row]
    }
    
    // Respond to the selected key
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        os_log("Key Selected", log: OSLog.default, type: .debug)
        
        // self.startingKeyChords.text = constructChordsInKey(keyOffset: row, majorKey: true)
    }
    

    // Construct a string of all chords in a Key starting with the root.
    func constructChordsInKey(keyOffset keyRow: Int, majorKey: Bool) -> String {
        let modeSteps: [Int] = (majorKey ? majorKeySteps : minorKeySteps)
        var nextChordOffset = keyRow
        var chords: String = "\(self.getKey(keyOffset: nextChordOffset)) "
        
        for cOffset in modeSteps {
            nextChordOffset = (nextChordOffset + cOffset) % self.circleOfFifthsSharps.count
            chords += "\(self.getKey(keyOffset: nextChordOffset)) "
        }
        return chords;
    }
    
    // Returns the Key based on the keyOffset and accounting for the setting of
    // the sharpsOrFlatsSwitch
    func getKey(keyOffset row: Int) -> String {
        var returnKey: String = "invalid"
        
        if (sharpsOrFlats) {
            returnKey = self.circleOfFifthsSharps[row]
        }
        else {
            returnKey = self.circleOfFifthsFlats[row]
        }
        
        return returnKey
    }
}
