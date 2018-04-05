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
//     X Create a major/minor key segmented control
//     X Fix Capo computation
//     - Complete the CircleOfFiftsPickerViewDelegate and CircleOfFifthsPickerViewDataSource
//       May be easier to have those as a single class, then split up to understand
//     - Implement the Target Key data using the CircleOfFifthsPickerViewDelegate
//     - Device adjustable display (iphone 6, 7, 8, etc), Vary For Traits in Storyboard editor
//     - Splash Screen (d'Arezzo, brought to you by Quebecois Engineering)
//     - Fixme's
//     X Implement Capo computation; make capo a text box, entering a number adjusts target key (picker, chords)
//     X Convert to 2 sharp/flat key switches, one for starting and one for target keys;
//         fix font sizes

//     X Solve the problem for special keys whose chords are not written correctly.
//         e.g., F has 1 flat (shown with A#), C has no accidentals (shown with E#),
//         All keys Sharps: C, C# (B not C as vii), D# (B#, Cx),
//                   Flats: A, B, D, E, G 
//     X Display major/minor/diminished for chord symbols. (tuple?  I: (0, ""), ii: (2, "m"), viidim: (7, "dim")
//     X Convert switches to a segmented control (2 options, Sharps or Flats)


import UIKit
import os.log

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startingKeySharpsOrFlats: UISegmentedControl!
    @IBOutlet weak var startingKeyPickerView: UIPickerView!
    @IBOutlet weak var startingKeyChords: UILabel!
    @IBOutlet weak var targetKeyPickerView: UIPickerView!
    @IBOutlet weak var targetKeyChords: UILabel!
    @IBOutlet weak var fretForCapo: UILabel!
    @IBOutlet weak var targetKeySharpsOrFlats: UISegmentedControl!
    @IBOutlet weak var modeSelectSetCtrl: UISegmentedControl!
    
    //MARK: local constants
    let circleOfFifthsSharps: [String] = ["A", "A♯", "B", "C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯"]
    let circleOfFifthsFlats: [String]  = ["A", "B♭", "B", "C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭"]
    
    /*
    // majorKeySteps is an array of tuples consisting of:
    //    1. the number of half-steps between the current chord and the next chord in the key.
    //    2. a character for the mode of the chord
    //
    // Major Key chord structure:  I ii iii IV V vi viidim I
    // Minor Key chord structure:  i ii(dim) III iv v VI VII
    */
    let majorKeySteps: [(Int, String)] = [(0, " "), (2, "m"), (2, "m"), (1, " ") , (2, " "), (2, "m"), (2, "○")]
    let minorKeySteps: [(Int, String)] = [(0, "m"), (2, "○"), (1, " "), (2, "m"), (2, "m"), (1, " "), (2, " ")]
    // sharps or flats selector indexes
    let sharpsSelected: Int = 0
    let flatsSelected:  Int = 1
    // mode indexes
    let majorModeSelected:  Int = 0
    let minorModeSelected: Int = 1
    
    //MARK: local vars
    // var targetKeyPickerDelegate :CircleOfFifthsPickerViewDelegate
    // FIXME: poor hack to get initializer to work right - majorKeySteps
    //    key concept: initializers in classes - empty, order of initialization, etc.
    var modeSelected: [(Int, String)] = [(0, " "), (2, "m"), (2, "m"), (1, " ") , (2, " "), (2, "m"), (2, "○")]
    // FIXME: add vars for:
    // startingKeyPickerViewDelegate, targetKeyPickerViewDelegate
    
    //MARK: boiler plate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        // FIXME: initialize delegates as in assignModeSelected
        // startingKeyPickerViewDelegate = CircleOfFifthsPickerViewDelegate(modeSelectSetCtrl.selectedSegmentIndex)
        self.startingKeyPickerView.delegate = self
        self.startingKeyPickerView.dataSource = self
        //
        self.targetKeyPickerView.delegate = self
        self.targetKeyPickerView.dataSource = self
        // Set initial mode
        assignModeSelected()
        
        //
        updateChords()
        // Capo
        updateCapo()
    }

    
    @IBAction func startingKeySharpsFlatsToggled(_ sender: UISegmentedControl) {
        updateChords()
        startingKeyPickerView.reloadComponent(0)
        os_log("Starting Sharp Keys toggled", log: OSLog.default, type: .debug)
    }
    
    @IBAction func targetSharpsOrFlatsToggled(_ sender: Any) {
        updateChords()
        targetKeyPickerView.reloadComponent(0)
        os_log("Target Sharp Keys toggled", log: OSLog.default, type: .debug)
    }

    @IBAction func modeSelectToggled(_ sender: UISegmentedControl) {
        assignModeSelected()
        updateChords()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Work functions
    
    // assign modeSelected
    func assignModeSelected() {
        switch (modeSelectSetCtrl.selectedSegmentIndex) {
        case majorModeSelected:
            modeSelected = majorKeySteps
            
        case minorModeSelected:
            modeSelected = minorKeySteps
        
        // FIXME: change to report an error
        //    key concept: error handling - throwing errors, etc
        default:
            modeSelected = majorKeySteps
        }
    }
    
    // Returns the Key based on the keyOffset and accounting for the setting of
    // the sharpsOrFlatsSwitch
    func getKey(keyOffset row: Int, forSharpKeys: Bool) -> String {
        var returnKey: String = "invalid"
        
        if (forSharpKeys) {
            returnKey = self.circleOfFifthsSharps[row]
        }
        else {
            returnKey = self.circleOfFifthsFlats[row]
        }
        
        return returnKey
    }
    
    // chordMode is "min", "" (Major) or "dim" for diminished
    func getChord(keyOffset row: Int, modeDesignator chordMode: String, forSharpKeys: Bool) -> String {
        return "\(getKey(keyOffset: row, forSharpKeys: forSharpKeys))\(chordMode)"
    }
    
    // Construct a string of all chords in a Key starting with the root.
    func constructChordsInKey(keyOffset keyRow: Int, sharpKeys: Bool) -> String {
        // let modeSteps: [(Int, String)] = (majorKey ? majorKeySteps : minorKeySteps)
        var nextChordOffset = keyRow
        var useSharpKeys: Bool
        // Root Chord for the key
        var chords: String = ""
        
        // adjust useSharpKeys based on the key
        switch (keyRow) {
        case 0, 2, 5, 7, 10: // Sharps only keys: (A,B,D,E,G)
            useSharpKeys = true
            
        case 8:  // Flats only key: F
            useSharpKeys = false
            
        default: // all others are based on sharpKeys
            useSharpKeys = sharpKeys
        }
        
        for (cOffset, modeStr) in modeSelected {
            nextChordOffset = (nextChordOffset + cOffset) % self.circleOfFifthsSharps.count
            chords += "\(getChord(keyOffset: nextChordOffset, modeDesignator: modeStr, forSharpKeys: useSharpKeys)) "
        }
        return chords;
    }
    
    func updateChords() {
        // starting key chords
        self.startingKeyChords.text = constructChordsInKey(
            keyOffset: self.startingKeyPickerView.selectedRow(inComponent: 0),
            // majorKey: true,
            sharpKeys: self.startingKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected)
        // target key chords
        self.targetKeyChords.text = constructChordsInKey(
            keyOffset: self.targetKeyPickerView.selectedRow(inComponent: 0),
            // majorKey: true,
            sharpKeys: targetKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected)
    }
    
    func updateCapo() {
        let targetKey = self.targetKeyPickerView.selectedRow(inComponent: 0)
        let startKey = self.startingKeyPickerView.selectedRow(inComponent: 0)
        if (startKey <= targetKey) {
            fretForCapo.text = String(targetKey - startKey)
        }
        else {
            fretForCapo.text = String(targetKey - startKey + circleOfFifthsSharps.count)
        }
        /*
        let startIdx = self.startingKeyPickerView.selectedRow(inComponent: 0)
        let targetIdx = self.targetKeyPickerView.selectedRow(inComponent: 0)
        var capoVal = 0
        var currIdx = startIdx
        while (currIdx != targetIdx) {
            currIdx = (currIdx + 1) % circleOfFifthsSharps.count
            capoVal += 1
        }
        fretForCapo.text = String(capoVal)
        */
    }
    
    //MARK: UIPickerViewDataSource

    
    // A CircleOfFifths picker has only one component, the single circle itself
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows in a CircleOfFifths picker is the number of keys (sharps or flats)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent componente: Int) -> Int {
        if (startingKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected) {
            return self.circleOfFifthsSharps.count
        }
        else {
            return self.circleOfFifthsFlats.count
        }
    }

    //MARK: UIPickerViewDelegate for Circle of Fifths
    // Return the key at the given row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.getKey(keyOffset: row,
                           forSharpKeys: (pickerView == startingKeyPickerView) ?
                               startingKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected :
                               targetKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected)
    }
    
    // Respond to the selected key
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == startingKeyPickerView) {
            os_log("Starting Key Selected", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Target Key Selected", log: OSLog.default, type: .debug)
        }

        //
        updateChords()
        updateCapo()
    }

}

