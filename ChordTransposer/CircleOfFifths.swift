//
//  CircleOfFifths.swift
//  ChordTransposer
//
//  Created by Michael Roy on 4/4/18.
//  Copyright © 2018 Quebecois Engineering. All rights reserved.
//

import Foundation
import UIKit
import os.log

class CircleOfFifths: NSObject, NSCoding {
    //MARK: local constants
    static let circleOfFifthsSharps: [String] = ["A", "A♯", "B", "C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯"]
    static let circleOfFifthsFlats: [String]  = ["A", "B♭", "B", "C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭"]
    
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
    var sharpKeysSelected: Bool
    var keySelected: Int32
    
    //MARK: Types
    struct PropertyKey {
        static let mode = "mode"
        static let sharps = "sharps"
        static let key = "key"
    }
    
    override init() {
        self.modeSelected = majorKeySteps
        self.keySelected = 0
        self.sharpKeysSelected = true
        
        super.init()
    }
    
    // add parameter for sharpKeysSelected
    init(aModeIndex: Int32, sharpKeysSelected: Bool, keySelected: Int32) {
        if (aModeIndex == 0) {
            self.modeSelected = majorKeySteps
        }
        else {
            self.modeSelected = minorKeySteps
        }
        self.sharpKeysSelected = sharpKeysSelected
        self.keySelected = keySelected
        
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
        aCoder.encode(sharpKeysSelected, forKey: PropertyKey.sharps)
        aCoder.encode(keySelected, forKey: PropertyKey.key)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let modeIndex = aDecoder.decodeInt32(forKey: PropertyKey.mode)   // major or minor keys
        let sharpKeys = aDecoder.decodeBool(forKey: PropertyKey.sharps)  // sharp or flat keys
        let theKey = aDecoder.decodeInt32(forKey: PropertyKey.key)       // the key itself

        self.init(aModeIndex: modeIndex, sharpKeysSelected: sharpKeys, keySelected: theKey)
    }
    
    //MARK: Interface Functions
    func setModeSelection(toMajor major: Bool) {
        if (major) {
            self.modeSelected = majorKeySteps
        }
        else {
            self.modeSelected = minorKeySteps
        }
    }
    
    static func count() -> Int {
        return circleOfFifthsSharps.count
    }
    
    //MARK: Worker Functions
    // assign modeSelected
    func assignModeSelected(selectedIndex: Int) {
        switch (selectedIndex) {
        case majorModeSelected:
            modeSelected = majorKeySteps
            
        case minorModeSelected:
            modeSelected = minorKeySteps
            
        default:
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // Returns the Key based on the keyOffset and accounting for the setting of
    // the sharpsOrFlatsSwitch
    func getChordAtPosition(chordPosition row: Int, forSharpKeys: Bool) -> String {
        var returnKey: String = "invalid"
        
        if (forSharpKeys) {
            returnKey = CircleOfFifths.circleOfFifthsSharps[row]
        }
        else {
            returnKey = CircleOfFifths.circleOfFifthsFlats[row]
        }
        
        return returnKey
    }
    
    // chordMode is "min", "" (Major) or "dim" for diminished
    func getChord(keyOffset row: Int, modeDesignator chordMode: String, forSharpKeys: Bool) -> String {
        return "\(getChordAtPosition(chordPosition: row, forSharpKeys: forSharpKeys))\(chordMode)"
    }
    
    // handles populating the text fields of the chordArray (UILabels), based
    // on the state of the CircleOfFifths object (sharps/flats, etc)
    fileprivate func adjustSharpsOrFlatsByKey(_ keyRow: Int) -> Bool {
        // start with the Tonic
        var useSharpKeys: Bool
        
        // adjust useSharpKeys based on the key
        switch (keyRow) {
        case 0, 2, 5, 7, 10: // Sharps only keys: (A,B,D,E,G)
            useSharpKeys = true
            
        case 8:  // Flats only key: F
            useSharpKeys = false
            
        default: // all others are based on sharpKeys
            useSharpKeys = self.sharpKeysSelected
        }
        return useSharpKeys
    }
    
    func constructChordsInKey(keyOffset keyRow: Int) -> String {
        var nextChordOffset = keyRow
        var chords: String = ""
        let useSharpKeys: Bool = adjustSharpsOrFlatsByKey(keyRow)
        
        for (cOffset, modeStr) in modeSelected {
            nextChordOffset = (nextChordOffset + cOffset) % CircleOfFifths.count()
            chords += "\(getChord(keyOffset: nextChordOffset, modeDesignator: modeStr, forSharpKeys: useSharpKeys)) "
        }
        return chords;
    }
    
    func populateChordArray( chordArray: inout [UILabel], keyOffset keyRow: Int) {
        var nextChordOffset = keyRow
        var chordInKey = 0
        let useSharpKeys: Bool = adjustSharpsOrFlatsByKey(keyRow)
        
        for (cOffset, modeStr) in modeSelected {
            nextChordOffset = (nextChordOffset + cOffset) % CircleOfFifths.count()
            chordArray[chordInKey].text = "\(getChord(keyOffset: nextChordOffset, modeDesignator: modeStr, forSharpKeys: useSharpKeys)) "
            chordInKey += 1
        }
    }
    
    // Returns the Key based on the keyOffset and sharpKeysSelected
    func getKey(keyOffset row: Int) -> String {
        var returnKey: String = "invalid"
        
        if (self.sharpKeysSelected) {
            returnKey = CircleOfFifths.circleOfFifthsSharps[row]
        }
        else {
            returnKey = CircleOfFifths.circleOfFifthsFlats[row]
        }
        
        return returnKey
    }
}
