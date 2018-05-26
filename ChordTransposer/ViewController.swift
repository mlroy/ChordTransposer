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
//     X Implement the originalKey and targetKey data using the CircleOfFifths class
//     later- Device adjustable display (iphone 6, 7, 8, etc), Vary For Traits in Storyboard editor
//     later- Splash Screen (d'Arezzo, brought to you by Quebecois Engineering)
//     X Fixme's (fixed initializer)
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
    @IBOutlet weak var targetKeyPickerView: UIPickerView!
    @IBOutlet weak var fretForCapo: UILabel!
    @IBOutlet weak var targetKeySharpsOrFlats: UISegmentedControl!
    @IBOutlet weak var modeSelectSetCtrl: UISegmentedControl!
    @IBOutlet weak var TargetKeyStackView: UIStackView!
    @IBOutlet weak var OriginalKeyStackView: UIStackView!
    
    //MARK: local constants
    // sharps or flats selector indexes
    let sharpsSelected: Int = 0
    let flatsSelected:  Int = 1
    // mode indexes
    let majorModeSelected:  Int = 0
    let minorModeSelected: Int = 1
    var targetKeyChordArray = [UILabel]()
    var originalKeyChordArray = [UILabel]()
    
    //MARK: local vars
    var originalKey: CircleOfFifths = CircleOfFifths()
    var targetKey: CircleOfFifths = CircleOfFifths()

    
    //MARK: ViewController common
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.startingKeyPickerView.delegate = self
        self.startingKeyPickerView.dataSource = self
        //
        self.targetKeyPickerView.delegate = self
        self.targetKeyPickerView.dataSource = self
        for kIndex in 0...7 {
            targetKeyChordArray.insert(UILabel(), at: kIndex)
            TargetKeyStackView.addArrangedSubview(targetKeyChordArray[kIndex])
            // original
            originalKeyChordArray.insert(UILabel(), at: kIndex)
            OriginalKeyStackView.addArrangedSubview(originalKeyChordArray[kIndex])
        }
        
        // Set initial mode
        assignModeSelected()
        // Chords
        updateChords()
        // Capo
        updateCapo()
    }
    
    @IBAction func startingKeySharpsFlatsToggled(_ sender: UISegmentedControl) {
        originalKey.sharpKeysSelected = (startingKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected)
        updateChords()
        startingKeyPickerView.reloadComponent(0)
        os_log("Starting Sharp Keys toggled", log: OSLog.default, type: .debug)
    }
    
    @IBAction func targetSharpsOrFlatsToggled(_ sender: Any) {
        targetKey.sharpKeysSelected = (targetKeySharpsOrFlats.selectedSegmentIndex == sharpsSelected)
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

    // MARK: Work functions
    
    func assignModeSelected() {
        switch (modeSelectSetCtrl.selectedSegmentIndex) {
        case majorModeSelected:
            originalKey.assignModeSelected(selectedIndex: majorModeSelected)
            targetKey.assignModeSelected(selectedIndex: majorModeSelected)
            
        case minorModeSelected:
            originalKey.assignModeSelected(selectedIndex: minorModeSelected)
            targetKey.assignModeSelected(selectedIndex: minorModeSelected)
        
        default:
            fatalError("assignModeSelected for invalid segment index")
        }
    }
    
    func updateChords() {
        self.targetKey.populateChordArray(chordArray: &self.targetKeyChordArray,
              keyOffset: self.targetKeyPickerView.selectedRow(inComponent: 0))
        self.originalKey.populateChordArray(chordArray: &self.originalKeyChordArray,
              keyOffset: self.startingKeyPickerView.selectedRow(inComponent: 0))
    }
    
    func updateCapo() {
        let targetKey = self.targetKeyPickerView.selectedRow(inComponent: 0)
        let startKey = self.startingKeyPickerView.selectedRow(inComponent: 0)
        if (startKey <= targetKey) {
            fretForCapo.text = String(targetKey - startKey)
        }
        else {
            fretForCapo.text = String(targetKey - startKey + CircleOfFifths.count())
        }
    }
    
    //MARK: UIPickerViewDataSource

    // A CircleOfFifths picker has only one component, the single circle itself
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows in a CircleOfFifths picker is the number of keys (sharps or flats)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent componente: Int) -> Int {
        return CircleOfFifths.count()
    }

    //MARK: UIPickerViewDelegate for Circle of Fifths
    // Return the key at the given row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var viewString: String = "invalid"
        
        if (pickerView == startingKeyPickerView) {
            viewString = originalKey.getKey(keyOffset: row)
        }
        else {
            viewString = targetKey.getKey(keyOffset: row)
        }
        return viewString
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

