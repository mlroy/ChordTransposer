//
//  CircleOfFifths.swift
//  ChordTransposer
//
//  Created by Michael Roy on 4/4/18.
//  Copyright © 2018 Quebecois Engineering. All rights reserved.
//

import Foundation
import os.log

class CircleOfFifths: NSObject, NSCoding {
    //MARK: local constants
    let circleOfFifthsSharps: [String] = ["A", "A♯", "B", "C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯"]
    let circleOfFifthsFlats: [String]  = ["A", "B♭", "B", "C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭"]
    
    /*
     // an array of tuples consisting of:
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
    var modeSelected: [(Int, String)]
    // var sharpKeysSelected: Boolean
    
    //MARK: Types
    struct PropertyKey {
        static let mode = "mode"
    }
    
    override init() {
        self.modeSelected = majorKeySteps
        super.init()
    }
    
    // add parameter for sharpKeysSelected
    init(aModeIndex: Int32) {
        if (aModeIndex == 0) {
            self.modeSelected = majorKeySteps
        }
        else {
            self.modeSelected = minorKeySteps
        }
        
        super.init()
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        let (_, modeStr) = modeSelected[0]
        var modeIndex: Int32 = 0 // major is the default
        
        if (modeStr == "m") {
            modeIndex = 1
        }
        aCoder.encode(modeIndex, forKey: PropertyKey.mode)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let modeIndex = aDecoder.decodeInt32(forKey: PropertyKey.mode)

        self.init(aModeIndex: modeIndex)
    }
    
    //MARK: Worker Functions
    // assign modeSelected
    func assignModeSelected(selectedIndex: Int) {
        switch (selectedIndex) {
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
            returnKey = circleOfFifthsSharps[row]
        }
        else {
            returnKey = circleOfFifthsFlats[row]
        }
        
        return returnKey
    }
    
    // chordMode is "min", "" (Major) or "dim" for diminished
    func getChord(keyOffset row: Int, modeDesignator chordMode: String, forSharpKeys: Bool) -> String {
        return "\(getKey(keyOffset: row, forSharpKeys: forSharpKeys))\(chordMode)"
    }
    
    // Construct a string of all chords in a Key starting with the root.
    func constructChordsInKey(keyOffset keyRow: Int, sharpKeys: Bool) -> String {
        var nextChordOffset = keyRow
        var useSharpKeys: Bool
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
            nextChordOffset = (nextChordOffset + cOffset) % circleOfFifthsSharps.count
            chords += "\(getChord(keyOffset: nextChordOffset, modeDesignator: modeStr, forSharpKeys: useSharpKeys)) "
        }
        return chords;
    }
}
