//
//  myNewTextfieldInt.swift
//  testinput
//
//  Created by Patrice Rapaport on 08/11/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

open class myTextFieldInt : cmyTextFieldNum {
    @IBInspectable var bz: Bool = false
    
    override open var stringValue: String {
        get {
            let S = super.stringValue
            if (S != "") {
                let f = Int(S)!
                if f == 0 && bz == true {
                    return ""
                }
                else {
                    return String(f)
                }
            }
            return super.stringValue
        }
        set (S) {
            if (S != "") {
                if Int(S) == 0 && bz == true {
                    super.stringValue = ""
                }
                else {
                    super.stringValue = String(S)
                }
            }
            else {
                if bz == true {
                    super.stringValue = ""
                } else {
                    super.stringValue=""
                }
            }
        }
    }
    
    var intVal: Int {
        get {
            return stringValue.toInt()
        }
        set (S) {
            stringValue = String(S)
        }
    }
    
    override open func acceptKey (event: NSEvent) -> Bool {
        if [ckeyboardKeys.leftArrow, ckeyboardKeys.rightArrow, ckeyboardKeys.delete].contains(event.keyCode) {
            return true
        }
        if (event.characters! < "0" || event.characters! > "9")  {
            return false
        } else {
            return true
        }
    }
}
