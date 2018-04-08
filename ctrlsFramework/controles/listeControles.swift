//
//  cmyControles.swift
//  testinput
//
//  Created by Patrice Rapaport on 15/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

class clisteControles {
    var controles: [cmyControl]=[]
    var myController: NSResponder!
    
    init (aController: NSResponder?) {
        myController = aController
    }
    
    deinit {
        if controles.count > 0 {
            controles.removeAll()
        }
    }
    
    func append (ctrl: NSControl, tabviewitem: NSTabViewItem?) {
        let aControl = cmyControl (ctrl, aParent: self, aTabview: tabviewitem)
        controles.append(aControl)
        
    }
    
    func append (aView: NSView, tabviewitem: NSTabViewItem?) {
        let aControl = cmyControl (aView, aParent: self, aTabview: nil)
        controles.append(aControl)
    }
    
    func append (tabview: NSTabView, tabviewitem: NSTabViewItem?) {
        let aControl = cmyControl (tabview, aParent: self, aTabview: nil)
        controles.append(aControl)
    }
    
    func append (aView: NSView,  table: NSTableView?) {
        let aControl = cmyControl (aView, aParent: self, aTableview: table!)
        controles.append(aControl)
    }
    
    func append (ctrl: NSControl, table: NSTableView?) {
        let aControl = cmyControl (ctrl, aParent: self, aTableview: table!)
        controles.append(aControl)
    }
    
    func setState (state: etatWindow) {
        if controles.count > 0 {
            for control in controles {
                if state == .edition && control.tabviewItem != nil && control.tabviewItem is cmyTabviewItem && (control.tabviewItem as! cmyTabviewItem).editionOnlyWhenSelected {
                    if control.tabviewItem.tabView?.selectedTabViewItem != control.tabviewItem {
                        continue
                    }
                } 
                control.setState(state: state)
            }
        }
    }
    
    func input (_ donnees: [String: String]) {
        input(donnees, item: nil)
    }
    
    func input (_ donnees: [String: String], item: NSTabViewItem!) {
        if controles.count > 0 {
            for control in controles {
                if item != nil {
                    if control.tabviewItem == nil || control.tabviewItem != item {
                        continue
                    }
                }
                let nomMethode: String = "aff"+(control.identifier.capitalized)+"WithCtrl:"
                let methode = Selector(nomMethode)
                if myController != nil && myController.responds (to: methode) {
                    let res = myController.perform(methode, with: control)
                    let value = Unmanaged<AnyObject>.fromOpaque(
                        res!.toOpaque()).takeUnretainedValue() as! String
                    control.input (value)
                } else {
                    let theIdentifier = control.identifier
                    if control.ctrl is cmyTextfieldAdresse && (control.ctrl as! cmyTextfieldAdresse).suffixe != "" {
                        //theIdentifier = (control.ctrl as! cmyTextfieldAdresse).identifierVirtuel()
                    }
                    if donnees.keys.contains(theIdentifier) {
                        if control.ctrl is cmyTextfieldAdresse {
                            control.input(donnees: donnees)
                        } else {
                            control.input(donnees[theIdentifier]!)
                        }
                    }
                }
                
                if control.ctrl is cmyTextfield && control.textColorMethod != nil {
                    let res = myController.perform(control.textColorMethod, with: donnees)
                    if res != nil {
                        let value = Unmanaged<AnyObject>.fromOpaque(
                            res!.toOpaque()).takeUnretainedValue() as! NSColor
                        (control.ctrl as! cmyTextfield).textColor =  value as NSColor
                    }
                }
            }
        }
    }
    func output()  -> [String: String] {
        var donnees: [String: String]!
        if myController is cbaseController {
            donnees = (myController as! cbaseController).donnees
        } else {
            if myController is cbaseView {
                donnees = (myController as! cbaseView).donnees
            }
        }
        for control in controles {
            var tabviewSelected: NSTabViewItem!
            if control.ctrl is NSTabView || control.isLabel {
                continue
            }
            if myController is cbaseController && (myController as! cbaseController).tabView != nil {
                tabviewSelected = (myController as! cbaseController).tabView.selectedTabViewItem
            }
            else
            if myController is cbaseView && (myController as! cbaseView).tabView != nil {
                tabviewSelected = (myController as! cbaseView).tabView.selectedTabViewItem
            }
            if control.tabviewItem == nil ||
                control.tabviewItem == tabviewSelected || !(control.tabviewItem as! cmyTabviewItem).editionOnlyWhenSelected {
                if control.ctrl is cmyTextfieldAdresse {
                    let res = control.output(donnees) as? [String: String]
                    for (cle, valeur) in res! {
                        var theCle = cle
                        if (control.ctrl as! cmyTextfieldAdresse).suffixe != "" {
                            theCle = theCle + (control.ctrl as! cmyTextfieldAdresse).suffixe
                        }
                        donnees[theCle] = valeur
                    }
                } else {
                    donnees[control.identifier] = control.output(donnees) as? String
                }
            }
        }
        return donnees
    }
    
    func getIndex (_ aControl: cmyControl) ->Int {
        for i in 0...controles.count-1 {
            if controles[i].identifier == aControl.identifier {
                return i
            }
        }
        return -1
    }
    
    func getControl (_ identifier: String) -> cmyControl? {
        if controles.count > 0 {
            for control in controles {
                if control.identifier == identifier {
                    return control
                }
            }
        }
        return nil
    }
    
    // Si le focus doit être passé à un control de type cmyTable et que cette table est en édition, on doit en fait le passer au premire contol éditable de la table
    func nextFocus(_ aControl: cmyControl) -> cmyControl? {
        if aControl.nextFocusControl != nil {
            let res = myController.perform(aControl.nextFocusControl, with: aControl.ctrl as! NSControl)
            if res == nil {
                return nil
            }
            let next = Unmanaged<AnyObject>.fromOpaque(
                res!.toOpaque()).takeUnretainedValue()
            return next as? cmyControl
        }
        var index = getIndex(aControl)
        while index != -1 && index < controles.count-1  {
            if controles[1+index].isLabel || !controles[1+index].isEnabled {
                index = index + 1
            }
            else {
                if aControl.tabviewItem != controles[1+index].tabviewItem {
                    return nil
                }
                if controles[1+index].ctrl is cmyTable {
                    let tbl = controles[1+index].ctrl as! cmyTable
                    if tbl.state != .nonedition && tbl.sourceRow(tbl.rowselected) != nil && tbl.sourceRow(tbl.rowselected).ctrls != nil {
                        for control  in tbl.sourceRow(tbl.rowselected).ctrls.controles {
                            if control.isEditable {
                                return control
                            }
                        }
                    }
                }
                return controles[1+index]
            }
        }
        return nil
    }
    
    func previousFocus(_ aControl: cmyControl) -> cmyControl? {
        var index = getIndex(aControl)
        while index != -1 && index > 0 {
            if controles[index - 1].isLabel && controles[1+index].isEnabled {
                index = index - 1
            }
            else {
                return controles[index - 1]
            }
        }
        return nil
    }
    
    func verifControl() ->Bool {
        for control in controles {
            if !control.verifControl() {
                return false
            }
        }
        return true
    }
}
