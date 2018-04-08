//
//  myNewtextfieldDecimal.swift
//  testinput
//
//  Created by Patrice Rapaport on 01/11/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

open class cmyTextFieldDecimal : cmyTextFieldNum {
    @IBInspectable var decimales: Int = 2
    @IBInspectable var bz: Bool = false
    @IBInspectable var monetaire: Bool = false
    
    var myFormat: NumberFormatter!
    
    func setformatter() {
        myFormat = NumberFormatter()
        myFormat.decimalSeparator = "."
        myFormat.format = "#.00"
    }
    
    override open var stringValue: String {
        get {
            let S = super.stringValue
            if (S != "") {
                guard let f = Float(S) else { return super.stringValue }
                if f == 0 && bz == true {
                    return ""
                }
                else {
                    let myFormat: String = "%."+String(decimales)+"f"
                    return String(format: myFormat,f)
                }
            }
            return super.stringValue
        }
        set (S) {
            if (myFormat == nil) {
                setformatter()
            }
            if (S != "") {
                if Float(S) == 0 && bz == true {
                    super.stringValue = ""
                }
                else {
                    if !monetaire {
                    super.stringValue = myFormat.string(from: myFormat.number(from: S)!)!
                    } else {
                        super.stringValue = S.toFloat().toMonetaire()
                    }
                }
            }
            else {
                if bz == true {
                    super.stringValue = ""
                } else {
                    super.stringValue="0.00"
                }
            }
        }
    }
    
    override open var floatValue: Float {
        get {
            return stringValue.toFloat()
        }
        set (S) {
            stringValue = String(S)
        }
    }
    
    override open func acceptKey (event: NSEvent) -> Bool {
        if [ckeyboardKeys.leftArrow, ckeyboardKeys.rightArrow, ckeyboardKeys.delete].contains(event.keyCode) {
            return true
        }
        if (event.characters! < "0" || event.characters! > "9") && ![".", ",", "-", "+", "*", "/",
                                                                     " ", "(", ")"].contains((event.characters)!)  {
            return false
        } else {
            return true
        }
    }
    
    func add (_ valeur: Float) {
        floatValue = floatValue + valeur
    }
}
