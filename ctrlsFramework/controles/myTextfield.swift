//
//  cmyTextfield.swift
//  testinput
//
//  Created by Patrice Rapaport on 19/10/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class cmyTextfield: NSTextField, NSTextFieldDelegate {
    var parent: cmyControl!
    @IBInspectable var obligatoire: Bool = false
    @IBInspectable var isFiltre: Bool = false
    @IBInspectable var onsubmit: Bool = false
    @IBInspectable var isLabel: Bool = false
    @IBInspectable var majuscules: Bool = false
    
    override open var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    var controller: NSResponder {
        get {
            return parent.controller
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        let bRes = super.becomeFirstResponder()
        if parent == nil {
            return true
        }
        
        parent.valeurAvant = stringValue
        if bRes {
            if parent != nil {
                if controller is cbaseController {
                    let theController = controller as! cbaseController
                    theController.currentFocus = parent
                    if parent.getfocusMethod != nil {
                        theController.perform(parent.getfocusMethod, with: self as NSControl)
                    }
                }
                else if controller is cbaseView {
                    let theController = controller as! cbaseView
                    theController.currentFocus = parent
                    if parent.getfocusMethod != nil {
                        theController.perform(parent.getfocusMethod, with: self as NSControl)
                    }
                }
            }
        }
        return bRes
    }
    
    override open func resignFirstResponder() -> Bool {
        return super.resignFirstResponder()
    }
    
    //procédure appelée quand on reçoit keyup
    func acceptKey (event: NSEvent) -> Bool {
        return true
    }
    
    func controlEnterRecu() {
        var valeur = stringValue
        let editor = currentEditor()
        if (editor == nil) {
            return
        }
        let range: NSRange = (editor?.selectedRange)!
        if range.location >= valeur.count {
            stringValue = valeur+"\n"
            return
        } else {
            valeur.insert("\n", at: valeur.index(valeur.startIndex, offsetBy: range.location))
        }
    }
    func verifObligatoire() ->Bool {
        if majuscules {
            stringValue = stringValue.uppercased()
        }
        if obligatoire {
            if stringValue == "" {
                return false
            }
        }
        return true
    }
    
    func verifCoherence()->Bool {
        return true
    }
    
    override open func keyDown(with event: NSEvent) {
        Swift.print("\(String(describing: identifier)) Keydow \(event)")
    }
}

