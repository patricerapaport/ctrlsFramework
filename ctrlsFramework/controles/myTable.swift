//
//  cmyTable.swift
//  testinput
//
//  Created by Patrice Rapaport on 21/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

// GESTION de la toolbar
//
// si la valeur boutonsAttaches de la table est ) true, c'est la table qui gère la toolbar (s'il n'y a pas d'onglet ou que le bon onglet est actif). Sinon la toolbar est gérée par cbaseController
// Quand selectionDidchange de cbaseController est appelée, on utilise boutonstoolbar de cbaseController si boutonsAttaches de la table est à faux, sinon pn utilise boutonstoolbar de la cmyTable
// Qund l'état de la table change, s'il y a des boutons attachés, la méthode boutonsattachesSetSate est appelée par la méthod setState de la table

enum sensTri: String {
    case asc = "asc"
    case desc = "desc"
}

class tblControles {
    var rng: Int
    var lstcontroles: clisteControles!
    init (aRow: Int) {
        rng = aRow
    }
}

open class cmyColumn: NSTableColumn {
    @IBInspectable var isSortable: Bool = false
    var sens: sensTri = .asc
    @IBInspectable var sensDefaut :String {
        get {
            return self.sens.rawValue
        }
        set( sens) {
            self.sens = sensTri(rawValue: sens) ?? .asc
        }
    }
}

open class cmyTable: NSTableView {
    var parent: cmyControl!
    var lastState: etatWindow = .nonedition
    var state: etatWindow = .nonedition
    var rowselected: Int = -1
    var draggedRow: Int!
    var rowAjoutee: Int = -1
    var newrow: [String: String]!
    var mySelectors: [cmySelector]!
    var boutonsToolbar: [cmyToolbarItem]!
    var triCourant: String = ""
    var btsAttaches: Bool = false
    var ascending: Bool = true
    @IBInspectable var isEditable: Bool = false
    @IBInspectable var rawColor: String!
    @IBInspectable var boutonsAttaches: Bool {
        get {
            return btsAttaches
        }
        set (b) {
            btsAttaches = b
        }
    }
    
    func setBoutonsAttaches() { // Cette fonction est appelée par le constructeur du parent (cmyControl)
        if (btsAttaches) {
            boutonsToolbar = []
            let controller = parent.controller as! cbaseController
            for item in controller.boutonsToolbar {
                boutonsToolbar.append(item)
            }
        }
    }
    
    func boutonsAttachesSetstate (state: etatWindow) {
        let controller = parent.controller as! cbaseController
        controller.viderToolbar()
        var index = 0
        for bouton in boutonsToolbar {
            bouton.setConfig(table: self)
            if (bouton.etatRequis == 0 && state == .nonedition) || (bouton.etatRequis == 1 && state != .nonedition) {
                if bouton.insertInToolbar(table: self, etat: state, index: index) {
                    index = index + 1
                }
            }
        }
    }
    
    var nouvellerangee: [String: String] { // pour créer une nouvelle rangée vide: cle/valeur Défaut
        get {
            if newrow == nil {
                let nomMethode: String =  "nouvelleRangeeWithCtrl:"
                let methode = Selector(nomMethode)
                if parent.controller.responds (to: methode) {
                    //controller.perform(methode)
                    let res = parent.controller.perform(methode, with:self)
                    let dict = Unmanaged<AnyObject>.fromOpaque(
                        res!.toOpaque()).takeUnretainedValue()
                    newrow = dict as! [String:String]
                } else {
                    return [:]
                }
            }
            return newrow
        }
        set (S) {
            newrow = S
        }
    }
    
    override open var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    
    override open func becomeFirstResponder() -> Bool {
        let bRes = super.becomeFirstResponder()
        if bRes {
            if parent != nil {
                if parent.controller is cbaseController {
                    (parent.controller as! cbaseController).currentFocus = parent
                }
                else
                if parent.controller is cbaseView {
                    (parent.controller as! cbaseView).currentFocus = parent
                }
            }
        }
        return bRes
    }
    
    override open func resignFirstResponder() -> Bool {
        return true
    }
    
    func mouseDown (event: NSEvent) {
        switch (event.type) {
        case .mouseExited, .mouseMoved, .leftMouseDragged,  .leftMouseUp, .scrollWheel,  .cursorUpdate: break
        case .leftMouseDown:
            Swift.print("\n\n")
            Swift.print("\(event.description)")
            //Swift.print("\(String(window?.mouseLocationOutsideOfEventStream))")
        default: break;
        }
    }
    
    func selectedRows () -> [Int] {
        var cids: [Int]=[]
        if numberOfRows > 0 {
            for index in 0...numberOfRows-1 {
                if isRowSelected(index) {
                    cids.append(index)
                }
            }
        }
        return cids
    }
    
    func sourceRow (_ row: Int) -> csourceTable {
        if row < self.parent.datasource.rows.count {
            return self.parent.datasource.rows[row]
        } else {
            return sourceRow(0)
        }
    }
    
    func getColumn (_ identifier: String) -> NSTableColumn? {
        for column in tableColumns {
            if column.identifier.rawValue == identifier {
                return column
            }
        }
        return nil
    }
    
    func getControl(_ identifier: String) ->cmyControl? { // retourne un cmyControl associé à la cellule
        if (rowselected != -1) {
            let row = sourceRow(rowselected)
            if row != nil && row.ctrls != nil {
                return row.getControl(identifier)!
            } else {
                let aRow = super.rowView (atRow: rowselected, makeIfNecessary: false)
                var i = 0
                for colonne in tableColumns {
                    if colonne.identifier.rawValue == identifier {
                        break
                    }
                    i = i+1
                }
                let aView: NSTableCellView? = aRow?.view(atColumn: i) as? NSTableCellView
                if (aView?.subviews.count)! > 0 {
                    if aView?.subviews[0] is cmyTextfield {
                        return (aView?.subviews[0] as! cmyTextfield).parent
                    }
                    else if aView?.subviews[0] is cmyCustomCheckbox  {
                        return (aView?.subviews[0] as! cmyCustomCheckbox).parent
                    }
                    else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
        } else {
            return nil;
        }
    }
    
    func getCellControl(_ identifier: String) ->NSControl? { // retourne un NSControl associé à la cellule
        if (rowselected != -1) {
            if sourceRow(rowselected) != nil && sourceRow(rowselected).ctrls != nil {
                return sourceRow(rowselected).getControl(identifier)?.ctrl as? NSControl
            } else {
                let aRow = super.rowView (atRow: rowselected, makeIfNecessary: false)
                var i = 0
                for colonne in tableColumns {
                    if colonne.identifier.rawValue == identifier {
                        break
                    }
                    i = i+1
                }
                let aView: NSTableCellView? = aRow?.view(atColumn: i) as? NSTableCellView
                if (aView?.subviews.count)! > 0 {
                    if aView?.subviews[0] is cmyTextfield {
                        return (aView?.subviews[0] as! cmyTextfield)
                    }
                    else if aView?.subviews[0] is cmyCustomCheckbox  {
                        return nil
                    }
                    else {
                        return nil
                    }
                } else {
                    return nil
                }
            }
        } else {
            return nil;
        }
    }
    
    func getCellControl (ixColumn: Int, ixRow: Int?) -> NSControl? {
        let nRow = ixRow == nil ? rowselected : ixRow
        let aRow = super.rowView (atRow: nRow!, makeIfNecessary: false)
        let aView: NSTableCellView? = aRow?.view(atColumn: ixColumn) as? NSTableCellView
        if (aView?.subviews.count)! > 0 {
            if aView?.subviews[0] is cmyTextfield {
                return (aView?.subviews[0] as! cmyTextfield)
            }
            else if aView?.subviews[0] is cmyCustomCheckbox  {
                return nil
            }
            else if aView?.subviews[0] is cmyControlDoc {
                return (aView?.subviews[0] as! cmyControlDoc)
            }
            else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func String (_ nomzone: String, _ row: Int) -> String {
        if row < numberOfRows {
            let rng = parent.datasource.rows[row]
            if rng.donnees.keys.contains(nomzone) {
                return rng.donnees[nomzone]!
            }
        }
        return ""
    }
    
    func String (_ nomzone: String) -> String {
        if selectedRow >= 0 {
            return String(nomzone, selectedRow)
        }
        return ""
    }
    
    func Int (_ nomzone: String) -> Int {
        return String(nomzone).toInt()
    }
    
    func Int(_ nomzone: String, _ row: Int) -> Int {
        return String(nomzone, row).toInt()
    }
    
    func Float (_ nomzone: String) -> Float {
        return String(nomzone).toFloat()
    }
    
    func Float (_ nomzone: String, _ row: Int) -> Float {
        return String(nomzone, row).toFloat()
    }
    
    func input (_ nomzone: String, valeur: String) {
        if selectedRow >= 0 {
            input(nomzone, valeur: valeur, row: selectedRow)
        }
    }
    
    func input (_ nomzone: String, valeur: String, row: Int) {
        if row >= 0 {
            let row = parent.datasource.rows[row]
            if row.donnees.keys.contains(nomzone) {
                row.donnees[nomzone] = valeur
            }
        }
    }
    
    func input (dict: [String:String], row: Int) {
        for (nomzone, valeur) in dict {
            input(nomzone, valeur: valeur, row: row)
        }
    }
    
    func input (dict: [String:String]) {
        if selectedRow >= 0 {
            input(dict: dict, row: selectedRow)
        }
    }
    
    func output () -> String {
        if (rowselected != -1) {
            sourceRow(rowselected).output()
            return sourceRow(rowselected).toString()
        } else {
            return "";
        }
    }
    
    func outputToDict() ->[String:String] {
        //let stringArray = output()
        let res : [String:String] = [:]
        //for string in stringArray {
        //}
        return res
    }
    
    func removeRow (_ row: Int) {
        if row != -1 {
            parent.datasource.rows.remove(at: row)
            reloadData()
        }
    }
    
    func selectRow (_ at: Int) {
        let index = NSIndexSet(index: at)
        selectRowIndexes(index as IndexSet, byExtendingSelection: false)
    }
    
    func setState (etat: etatWindow) {
        lastState = state
        if etat != .nonedition && !isEditable {
            return
        }
        if btsAttaches && parent.controller is cbaseController  {
            if boutonsToolbar == nil {
                (parent.controller as! cbaseController).setConfigs()
            }
            boutonsAttachesSetstate(state: etat)
        }
        if rowselected > -1 && rowselected <= numberOfRows {
            let aSourceRow = sourceRow(lastState == .ajout ? rowAjoutee : rowselected)
            if aSourceRow.ctrls != nil {
                aSourceRow.ctrls.setState(state: etat)
            }
        } else if rowAjoutee > -1 {
            let aSourceRow = sourceRow(rowAjoutee)
            if aSourceRow.ctrls != nil {
                aSourceRow.ctrls.setState(state: etat)
            }
        }
        state = etat
        if parent != nil && parent.etat != etat {
            parent.etat = etat
        }
        if (etat == .nonedition) {
            let responder = parent.window
            if responder is NSWindow {
                (responder as? NSWindow)?.makeFirstResponder(nil)
            }
            rowAjoutee = -1
            selectionHighlightStyle = .regular
            parent.makeFirstResponder()
            //let index = NSIndexSet(index: rowselected)
            //selectRowIndexes(index as IndexSet, byExtendingSelection: false)
        } else {
            if rowselected != -1 && isEditable {
                selectionHighlightStyle = .none
            }
        }
    }
    
    func setControls (aRow: NSTableRowView, source: csourceTable) {
        if source.ctrls == nil {
            source.ctrls = clisteControles(aController: parent.controller)
            for i in 0...tableColumns.count-1 {
                if !tableColumns[i].isEditable {
                    continue
                }
                let aView: NSTableCellView? = aRow.view(atColumn: i) as? NSTableCellView
                if aView != nil {
                    if (aView?.subviews.count)! > 1 { // plusieurs controles dans la cellule
                        if aView?.subviews[0] is cmyCombo && aView?.subviews[1] is cmyTextfield {
                            (aView?.subviews[0] as! cmyCombo).txtassocie = (aView?.subviews[1] as! cmyTextfield)
                            if state != .nonedition {
                                (aView?.subviews[1] as! cmyTextfield).isHidden = true
                                (aView?.subviews[0] as! cmyCombo).isHidden = false
                            }
                        }
                        else if aView?.subviews[0] is cmyCustomCheckbox && aView?.subviews[1] is cmyTextfield {
                            (aView?.subviews[0] as! cmyCustomCheckbox).txtassocie = (aView?.subviews[1] as! cmyTextfield)
                            if state != .nonedition {
                                (aView?.subviews[1] as! cmyTextfield).isHidden = true
                                (aView?.subviews[0] as! cmyCustomCheckbox).isHidden = false
                            }
                        }
                    }
                    
                    // ajout des controles à souce.ctrls
                    if aView?.subviews[0] is NSControl {
                        source.ctrls.append(ctrl: aView?.subviews[0] as! NSControl, table: self)
                        if aView?.subviews[0] is cmyTextfield && state != .nonedition{
                            (aView?.subviews[0] as! cmyTextfield).isBezeled = true
                        }
                    }
                    else if aView?.subviews[0] is cmyCustomCheckbox {
                        source.ctrls.append(aView: (aView?.subviews[0])!, table: self)
                    }
                    
                    if state != .nonedition && aView?.subviews[0] is cmyCombo && aView?.subviews[1] is cmyTextfield {
                        (aView?.subviews[0] as! cmyCombo).stringValue = (aView?.subviews[1] as! cmyTextfield).stringValue
                    }
                    else if state != .nonedition && aView?.subviews[0] is cmyCustomCheckbox && aView?.subviews[1] is cmyTextfield {
                        (aView?.subviews[0] as! cmyCustomCheckbox).stringValue = (aView?.subviews[1] as! cmyTextfield).stringValue
                    }
                }
            }
        }
    }
    
    func resetControls(aRow: NSTableRowView, source: csourceTable) {
        for i in 0...tableColumns.count-1 {
            if !tableColumns[i].isEditable {
                continue
            }
            let aView: NSTableCellView? = aRow.view(atColumn: i) as? NSTableCellView
            if aView != nil {
                if (aView?.subviews.count)! > 1 { // plusieurs controles dans la cellule
                    if aView?.subviews[0] is cmyCombo && aView?.subviews[1] is cmyTextfield {
                        (aView?.subviews[1] as! cmyTextfield).isHidden = false
                        (aView?.subviews[0] as! cmyCombo).isHidden = true
                    } else {
                        if parent.controller is cbaseController && (parent.controller as! cbaseController).currentFocus == aView?.subviews[0] {
                            (parent.controller as! cbaseController).currentFocus = nil
                        }
                        if aView?.subviews[0] is cmyCustomCheckbox && aView?.subviews[1] is cmyTextfield {
                            (aView?.subviews[1] as! cmyTextfield).isHidden = true
                            (aView?.subviews[0] as! cmyCustomCheckbox).isHidden = false
                        }
                    }
                }
                if aView?.subviews[0] is NSControl {
                    if aView?.subviews[0] is cmyTextfield {
//Swift.print("\((aView?.subviews[0] as! cmyTextfield).parent.identifier)")
                        (aView?.subviews[0] as! cmyTextfield).isBezeled = false
                        if parent.controller is cbaseController && (parent.controller as! cbaseController).currentFocus != nil && (parent.controller as! cbaseController).currentFocus.identifier == (aView?.subviews[0] as! cmyTextfield).parent.identifier {
                            (parent.controller as! cbaseController).currentFocus = nil
                        }
                    }
                }
            }
        }
        source.ctrls.controles.removeAll()
        source.ctrls = nil
    }
    
    // les controles n'existent que quand il y a saisie
    open override func rowView(atRow row: Int, makeIfNecessary: Bool) -> NSTableRowView? {
        let aRow = super.rowView (atRow: row, makeIfNecessary: makeIfNecessary)
        if aRow == nil {
            return nil
        }
        
        // si la liste des controles pour cette rangée n'existe pas dans la cource de données, on la construit
        let aSourceRow = sourceRow(row)
        
        if aSourceRow.ctrls == nil {
            setControls(aRow: aRow!, source: aSourceRow)
        }
        return aRow
    }
}

//MARK: mySelectorProtocol
extension cmyTable: mySelectorProtocol {
    var selectors: [cmySelector]  {
        get {
            if mySelectors == nil {
                mySelectors = []
            }
            return mySelectors
        }
        set (S) {
            mySelectors = S
        }
    }
    
}
