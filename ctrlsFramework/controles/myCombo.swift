    //
//  cmyCombo.swift
//  testinput
//
//  Created by Patrice Rapaport on 18/10/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class cmyCombo: NSComboBox {
    var parent: cmyControl!
    var valeurInitiale: String!
    var txtassocie: cmyTextfield! // utilisé dans une cellule de table
    var chgtInterne: Bool = false // si positionné à true, la méthode chgt ne sera pas appelée dans selectionddchange
    @IBInspectable var obligatoire: Bool = false
    @IBInspectable var isFiltre: Bool = false
    @IBInspectable var isLabel: Bool = false
     @IBInspectable var isBloque: Bool = false
    
    var controller: NSResponder {
        get {
            return parent.controller
        }
    }
    
    
    override open var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        if parent == nil {
            return true
        }
        if (parent.tableView != nil && parent.tableView is cmyTable && (parent.tableView as! cmyTable).state == .nonedition) || (parent.tableView == nil && parent.controllerState == .nonedition) && !isFiltre {
            return false
        }
        let bRes = super.becomeFirstResponder()
        if bRes {
            if parent != nil {
                if controller is cbaseController {
                    (controller as! cbaseController).currentFocus = parent
                }
                else
                if controller is cbaseView {
                    (controller as! cbaseView).currentFocus = parent
                }
            }
        }
        return bRes
    }
    
    override open func resignFirstResponder() -> Bool {
        return true
    }
    
    override open var stringValue: String {
        get {
            return super.stringValue
        }
        set (S) {
            let index = getIndex(valeur: S)
            if index != -1 {
                selectItem(at: index)
                super.stringValue = objectValueForItemAt(index) as! String
                scrollItemAtIndexToTop(index)
            } else {
                super.stringValue = ""
            }
        }
    }
    
    func getIndex (_ cle: String) ->Int {
        if parent == nil || parent.source == nil {
            if numberOfItems >= cle.toInt() {
                return cle.toInt()
            }
            return -1
        }
        if parent.source != nil && parent.source.count > 0 {
            for i in 0...parent.source.count-1 {
                if parent.source[i].equal(key: cle) {
                    return i
                }
            }
        }
        return -1
    }
    
    func keyValue() -> String {
        return getKey(selection: indexOfSelectedItem)
    }
    
    func keyValue(valeur:String) -> String {
        return getKey(valeur: valeur)
    }
    
    // retourne l'index pour une valeur donnée
    func getIndex(valeur: String) -> Int {
        if parent != nil && parent.source != nil && parent.source.count > 0 {
            for i in 0...parent.source.count-1 {
                if parent.source[i].equal(value: valeur) {
                    return i
                }
            }
        } else {
            if numberOfItems == 0 {
                return -1
            }
            for i in 0...numberOfItems-1 {
                if objectValueForItemAt(i) as! String == valeur {
                    return i
                }
            }
        }
        return -1
    }
    
    func getKey (selection: Int) -> String {
        if parent.source == nil {
            return ""
        }
        return selection < parent.source.count && selection != -1 ? parent.source[selection].cle : ""
    }
    
    func getKey (valeur: String) -> String {
        if parent.source == nil {
            return ""
        } else {
            return getKey(selection: getIndex(valeur: valeur))
        }
    }
    
    func setKey (_ aValue: String) {
        let index = getIndex(aValue)
        if (index != -1) {
            selectItem(at: index)
            if parent == nil || parent.source == nil {
                return
            }
            let exChgtInterne = chgtInterne
            chgtInterne = true
            // if !chgtInterne {
            //     stringValue = parent.source == nil ? "" : parent.source[index].valeur
            //} else {
            super.stringValue = parent.source == nil ? "" : parent.source[index].valeur
            //}
            chgtInterne = exChgtInterne
            valeurInitiale = stringValue
        } else {
            stringValue = ""
        }
    }
    
    func input (_ aValue: String) {
        let index =  getIndex(aValue)
        if (index != -1) {
            selectItem(at: index)
            if parent == nil || parent.source == nil {
                return
            }
            let exChgtInterne = chgtInterne
            chgtInterne = true
           // if !chgtInterne {
           //     stringValue = parent.source == nil ? "" : parent.source[index].valeur
            //} else {
                super.stringValue = parent.source == nil ? "" : parent.source[index].valeur
            //}
            chgtInterne = exChgtInterne
            valeurInitiale = stringValue
        } else {
            stringValue = ""
        }
    }
    
    func input (valeur: String) {
        let index =  getIndex(valeur: valeur)
        if (index != -1) {
            stringValue = parent.source == nil ? "" : parent.source[index].valeur
            //selectItem(withObjectValue: stringValue)
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if parent == nil || parent.source == nil {
            return 0
        } else {
            return parent.source.count
        }
    }
    
    func objectValueForItemAt(_ index: Int) -> Any? {
        if parent == nil || parent.source == nil  || index == -1 {
            return super.itemObjectValue(at: index)
        } else if parent.source.count > index {
            return parent.source[index].valeur
        } else {
            return ""
        }
    }
    
    func indexOfItemWithStringValue (_ string: String) -> Int {
        if parent == nil || parent.source == nil  {
            return -1
        } else {
            return getIndex(valeur: string)
        }
    }
    
    func completedString(_ string: String) -> String? {
        if parent == nil || parent.source == nil || parent.source.count == 0{
            if numberOfItems > 0 {
                for i in 0...numberOfItems-1 {
                    let S: String = itemObjectValue(at: i) as! String
                    if string.lowercased() == S.substr(from:0, to: string.count-1).lowercased() {
                        return S
                    }
                }
            }
            return nil
        }
        
        for i in 0...parent.source.count-1 {
            let valeur: String? = parent.source[i].equalsPartiel(partialValue: string)
            if (valeur != nil) {
                return valeur
            }
        }
        
        return nil
    }
    
    func selectionDidChange() {
        if (parent.controllerState == .nonedition && isFiltre == false) ||
            (isFiltre && isBloque == true){
            if valeurInitiale == nil {
                valeurInitiale = ""
            }
            selectItem(at: getIndex(valeur: valeurInitiale))
            input(valeur: valeurInitiale)
        }
        else {
            selectItem(at: indexOfSelectedItem)
            if !chgtInterne {
                let nomMethode: String = "chgt"+(self.identifier?.rawValue.capitalized)!+"WithCtrl:"
                let methode = Selector(nomMethode)
                if controller.responds (to: methode) {
                    controller.perform(methode, with:self as NSControl)
                }
            }
        }
    }
    
    override open func keyUp(with event: NSEvent) {
        if (event.keyCode == ckeyboardKeys.enter || event.keyCode == ckeyboardKeys.enterNum || event.keyCode == ckeyboardKeys.tab) {
            parent.enterReceived (event)
        }
        else
            if event.keyCode ==  ckeyboardKeys.escape {
                parent.escapeReceived(event)
        }
    }
    
    func verifObligatoire() ->Bool {
        if txtassocie != nil {
            txtassocie.stringValue = stringValue
        }
        if obligatoire {
            if stringValue == "" {
                return false
            }
        }
        return true
    }
}
