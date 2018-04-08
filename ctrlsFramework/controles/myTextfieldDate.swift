//
//  myNewtextfieldDate.swift
//  testinput
//
//  Created by Patrice Rapaport on 03/11/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

open class cmyTextfieldDate : cmyTextfield {
    var mm : Int!
    var jj: Int!
    var aa : Int!
    
    override open var stringValue: String {
        get {
            let now = Date()
            var reecrit = false
            if super.stringValue == "" {
                return super.stringValue
            }
            if super.stringValue.contains("-") {
                var els = super.stringValue.components(separatedBy: "-")
                aa = els.count > 0 && els[0] != "" ? els[0].toInt() : 0
                mm = els.count > 1 ? els[1].toInt() : 0
                jj = els.count > 2 ? els[2].toInt() : 0
            } else {
                var els = super.stringValue.components(separatedBy: "/")
                aa = els.count > 2 ? els[2].toInt() : 0
                mm = els.count > 1 ? els[1].toInt() : 0
                jj = els.count > 0 && els[0] != "" ? els[0].toInt() : 0
            }
            if mm == 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM"
                mm = formatter.string(from: now).toInt()
                formatter.dateFormat = "yyyy"
                aa = formatter.string(from: now).toInt()
                reecrit = true
            }
            if jj == 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "DD"
                jj = formatter.string(from: now).toInt()
                reecrit = true
            }
            if aa == 0 {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy"
                aa = formatter.string(from: now).toInt()
                reecrit = true
            }
            if aa != 0 && mm != 0 && jj != 0 {
                let res =  String(format: "%04d-%02d-%02d", aa, mm, jj)
                if reecrit {
                    super.stringValue = res
                }
                return res
            }
            else {
                return ""
            }
        }
        set (S) {
            if (S == "") {
                jj = 0
                mm = 0
                aa = 0
                super.stringValue = S
            }
            else {
                var els = S.components(separatedBy: "-")
                aa = els.count > 0 ? Int(els[0]) : 0
                mm = els.count > 1 ? Int(els[1]) : 0
                jj = els.count > 2 ? Int(els[2]) : 0
                if aa != 0 && mm != 0 && jj != 0 {
                    super.stringValue =  String(format: "%02d/%02d/%04d", jj, mm, aa)
                }
                else {
                    super.stringValue = ""
                }
            }
        }
    }
    
    override open func acceptKey (event: NSEvent) -> Bool {
        if [ckeyboardKeys.leftArrow, ckeyboardKeys.rightArrow, ckeyboardKeys.delete].contains(event.keyCode) {
            return true
        }
        if ((event.characters! < "0") || (event.characters! > "9")) && event.characters != "/" {
            return false
        } else {
            if (event.type == .keyUp) {
                let editor = currentEditor()
                if (editor == nil) {
                    return true
                }
                let range: NSRange = (editor?.selectedRange)!
                if range.length > 0 {
                    // effacer la sélection
                    var S: String = ""
                    var index = 0
                    for char in super.stringValue {
                        if index < range.location || index > range.location + range.length {
                            S.append(char)
                        }
                        index += 1
                    }
                    self.stringValue = S
                    
                    //for char in super.stringValue.characters {
                      //  if index < range.location || index > range.location + range.length {
                        //    S.append(char)
                        //}
                        //index += 1
                    //}
                    //self.stringValue = S
                }
                if super.stringValue.count >= 10 {
                    return false
                }
                if (event.type == .keyUp && (range.location == 2 || range.location == 5 )) {
                    super.stringValue = super.stringValue + "/"
                }
            }
            return true
        }
    }
    
    override open func insertText(_ insertString: Any) {
        Swift.print("\(String(describing: identifier)) InsertText: \(insertString)")
        
        super.insertText(insertString)
    }
    
    override open func verifCoherence() ->Bool {
        var jourOK = true
        let S = self.stringValue
        if (S == "") {
            return true
        }
        if mm < 1 || mm > 12 {
            parent.popover("Mois erroné")
            return false
        }
        switch (mm) {
        case 1, 3, 5, 7, 8, 10, 12:
            jourOK = jj <= 31
        case 2:
            if aa % 400 == 0 || (aa % 100 != 0 && aa % 4 == 0) {
                jourOK = jj <= 29
            }
            else {
                jourOK = jj <= 28
            }
        default:
            jourOK = jj <= 30
        }
        if (!jourOK) {
            parent.popover("jour erroné")
            return false
        }
        self.stringValue = S
        return super.verifCoherence()
    }
    
    func toSaisie() ->String {
        return cDates(stringValue).toSsaisie()
    }
}
