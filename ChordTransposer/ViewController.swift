//
//  ViewController.swift
//  ChordTransposer
//
//  Created by Michael Roy on 2/26/18.
//  Copyright © 2018 Quebecois Engineering. All rights reserved.
//
// Useful concepts:  UIPickerView, view/data/delegate/controller,
//                   Swift Language, Classes & initialization, Debugging
//                   Splash Screen
//
//  Next Steps:
//     - Complete the CircleOfFiftsPickerViewDelegate and CircleOfFifthsPickerViewDataSource
//       May be easier to have those as a single class, then split up to understand
//     - Implement the Target Key data using the CircleOfFifthsPickerViewDelegate
//     - Implement Capo computation; make capo a text box, entering a number adjusts target key (picker, chords)
//     - Convert to 2 sharp/flat key switches, one for starting and one for target keys;
//         fix font sizes
//     - Create a major/minor key switch
//     - Solve the problem for special keys whose chords are not written correctly.
//         e.g., F has 1 flat (shown with A#), C has no accidentals (shown with E#),
//         All keys Sharps: C, C# (B not C as vii), D# (B#, Cx),
//                   Flats: A, B, D, E, G 
//     - Display major/minor/diminished for chord symbols. (tuple?  I: (0, ""), ii: (2, "m"), viidim: (7, "dim")
//     - Device adjustable display (iphone 6, 7, 8, etc)
//     - Splash Screen (d'Arezzo, brought to you by Quebecois Engineering)

import UIKit
import os.log

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var sharpsOrFlatsLabel: UILabel!
    @IBOutlet weak var sharpsOrFlatsSwitch: UISwitch!
    @IBOutlet weak var startingKeyPickerView: UIPickerView!
    @IBOutlet weak var startingKeyChords: UILabel!
    
    
    //MARK: local data
    let circleOfFifthsSharps: [String] = ["A ", "A♯", "B ", "C ", "C♯", "D ", "D♯", "E ", "E♯", "F♯", "G ", "G♯"]
    let circleOfFifthsFlats: [String]  = ["A ", "B♭", "B ", "C ", "D♭", "D ", "E♭", "E ", "F ", "G♭", "G ", "A♭"]
    // majorKeySteps is an array of the number of half-steps between the current
    // chord and the next chord in the key.
    // Major Key chord structure:  I ii iii IV V vi viidim I
    let majorKeySteps: [Int] = [2, 2, 1, 2, 2, 2]
    // Minor Key chord structure:  i ii(dim) III iv v VI VII
    let minorKeySteps: [Int] = [2, 1, 2, 2, 1, 2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.startingKeyPickerView.delegate = self
        self.startingKeyPickerView.dataSource = self
        
        // self.startingKeyChords.text = constructChordsInKey(keyOffset: 0, majorKey: true)
        self.startingKeyChords.text = constructChordsInKey(
           keyOffset: self.startingKeyPickerView.selectedRow(inComponent: 0),
           majorKey: true)
    }

    @IBAction func sharpsOrFlatsToggled(_ sender: UISwitch) {
        if (sender.isOn) {
            sharpsOrFlatsLabel.text = "Sharp Keys"
            self.startingKeyChords.text = constructChordsInKey(
                keyOffset: self.startingKeyPickerView.selectedRow(inComponent: 0),
                majorKey: true)
        }
        else {
            sharpsOrFlatsLabel.text = "Flat Keys"
            self.startingKeyChords.text = constructChordsInKey(
                keyOffset: self.startingKeyPickerView.selectedRow(inComponent: 0),
                majorKey: true)
        }
        
        startingKeyPickerView.reloadComponent(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Work functions
    
    // Returns the Key based on the keyOffset and accounting for the setting of
    // the sharpsOrFlatsSwitch
    func getKey(keyOffset row: Int) -> String {
        var returnKey: String = "invalid"
        
        if (sharpsOrFlatsSwitch.isOn) {
            returnKey = self.circleOfFifthsSharps[row]
        }
        else {
            returnKey = self.circleOfFifthsFlats[row]
        }
        
        return returnKey
    }
    
    // Construct a string of all chords in a Key starting with the root.
    func constructChordsInKey(keyOffset keyRow: Int, majorKey: Bool) -> String {
        let modeSteps: [Int] = (majorKey ? majorKeySteps : minorKeySteps)
        var nextChordOffset = keyRow
        var chords: String = "\(getKey(keyOffset: nextChordOffset)) "
        
        for cOffset in modeSteps {
            nextChordOffset = (nextChordOffset + cOffset) % self.circleOfFifthsSharps.count
            chords += "\(getKey(keyOffset: nextChordOffset)) "
        }
        return chords;
    }
    
    //MARK: UIPickerViewDataSource
    //MARK: UIPickerViewDelegate for Circle of Fifths
    
    // A CircleOfFifths picker has only one component, the single circle itself
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows in a CircleOfFifths picker is the number of keys (sharps or flats)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent componente: Int) -> Int {
        if (sharpsOrFlatsSwitch.isOn) {
            return self.circleOfFifthsSharps.count
        }
        else {
            return self.circleOfFifthsFlats.count
        }
    }

    // Return the key at the given row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.getKey(keyOffset: row)
    }
    
    // Respond to the selected key
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        os_log("Starting Key Selected", log: OSLog.default, type: .debug)
        
        self.startingKeyChords.text = constructChordsInKey(keyOffset: row, majorKey: true)
    }

}

