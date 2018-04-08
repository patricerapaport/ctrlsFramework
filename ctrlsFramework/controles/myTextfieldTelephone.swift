//
//  myTextfieldTelephone.swift
//  ctrlsFramework
//
//  Created by Patrice Rapaport on 07/04/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Foundation

open class cmyTextfieldTelephone: cmyTextfield {
    
    override open var stringValue: String {
        get {
            var res: String = ""
            var index = 0
            for char in super.stringValue {
                if char != " " {
                    res = res + String(char) //.characters.append(character)
                }
                index = index + 1
            }
            return res
        }
        set (S) {
            let str: String = S
            var res: String = ""
            var index = 0
            for char in str {
                if (index > 0 && index % 2 == 0) {
                    res = res + " "
                }
                res.insert(char, at: res.endIndex)
                index = index + 1
            }
            super.stringValue = res
        }
    }
    
    override open func acceptKey (event: NSEvent) -> Bool {
        if [ckeyboardKeys.leftArrow, ckeyboardKeys.rightArrow, ckeyboardKeys.delete].contains(event.keyCode) {
            return true
        }
        if ((event.characters! < "0") || (event.characters! > "9")) && event.characters != " " {
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
                    for char in self.stringValue {
                        if index < range.location || index > range.location + range.length {
                            S.append(char)
                        }
                        index += 1
                    }
                    self.stringValue = S
                }
                if self.stringValue.count == 10 {
                    return false
                }
                if (event.type == .keyUp && (range.location == 2 || range.location == 6 || range.location == 9 || range.location == 12)) {
                    self.stringValue = self.stringValue + " "
                }
                
            }
            return true
        }
    }
    
    override open func verifCoherence()->Bool {
        let S = stringValue
        if (S.count > 0 && S.count < 10) {
            parent.popover ("Format de téléphone erroné")
            return false
        } else {
            return true
        }
    }
}
