//
//  cmyControl.swift
//  testinput
//
//  Created by Patrice Rapaport on 15/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

class myNewOption {
    var cle: String
    var valeur: String
    
    init (key: String, value: String) {
        cle=key
        valeur=value
    }
    
    func equal (key: String)->Bool {
        return key == cle
    }
    
    func equal (value: String) ->Bool {
        return valeur == value
    }
    
    func equalsPartiel (partialValue: String) -> String? {
//let index = valeur.index(valeur.startIndex, offsetBy: partialValue.count)
        if partialValue.lowercased() == valeur.substr(from: 0, to:partialValue.count-1).lowercased() {
            return valeur
        }
        return nil
    }
}

open class cmyControl: NSObject {
    var ctrl: NSView
    var tabviewItem: NSTabViewItem!
    var tableView: NSTableView!
    var outlineView: NSOutlineView!
    var boxView: NSBox!
    var etat: etatWindow = .nonedition
    var valeurAvant: String!
    var parent: clisteControles!
    var source: [myNewOption]! // valable uniquement si ctrl est NSComboBox
    var datasource: crowsTable! // valable uniquement si ctrl est NSTableView
    var verifControlMethod: Selector!
    var nextFocusControl: Selector!
    var getfocusMethod: Selector!
    var acceptKeyMethod: Selector!
    var textColorMethod: Selector!
    var mySelectors: [cmySelector]!
    
    var isSelectable: Bool {
        get {
            if ctrl is NSTextField {
                return (ctrl as! NSTextField).isSelectable
            } else {
                return false
            }
        }
        set (selectable) {
            if ctrl is NSTextField {
                (ctrl as! NSTextField).isSelectable = selectable
            }
        }
    }
    
    var isBezeled: Bool {
        get {
            if ctrl is NSTextField {
                return (ctrl as! NSTextField).isBezeled
            } else {
                return false
            }
        }
        set (bezeled) {
            if ctrl is NSTextField {
                (ctrl as! NSTextField).isBezeled = bezeled
            }
        }
    }
    
    var isEditable: Bool {
        get {
            if ctrl is NSTextField {
                return (ctrl as! NSTextField).isEditable
            } else {
                return false
            }
        }
        set (editable) {
            if ctrl is NSTextField {
                (ctrl as! NSTextField).isEditable = editable
            }
        }
    }
    
    var isEnabled: Bool {
        get {
            if ctrl is NSControl {
                return (ctrl as! NSControl).isEnabled
            } else {
                return true
            }
        }
        set (enabled) {
            if ctrl is NSControl {
                (ctrl as! NSControl).isEnabled = enabled
            }
        }
    }
    
    var isHidden: Bool {
        get {
            return ctrl.isHidden
        }
        set (hidden) {
            ctrl.isHidden = hidden
        }
    }
    
    var isFiltre: Bool {
        get {
            if ctrl is cmyTextfield {
                return (ctrl as! cmyTextfield).isFiltre
            }
            else
            if ctrl is cmyCombo {
                return (ctrl as! cmyCombo).isFiltre
            }
            else if ctrl is cmyCustomCheckbox {
                return (ctrl as! cmyCustomCheckbox).isFiltre
            }
            else {
                return false
            }
        }
    }
    
    var isLabel: Bool {
        get {
            if ctrl is cmyTextfield {
                return (ctrl as! cmyTextfield).isLabel
            } else if ctrl is cmyCombo {
                return (ctrl as! cmyCombo).isLabel
            } else {
                return false
            }
        }
        set (bLabel) {
            if ctrl is cmyTextfield {
                (ctrl as! cmyTextfield).isLabel = bLabel
            } else if ctrl is cmyCombo {
                (ctrl as! cmyCombo).isLabel = bLabel
            } 
        }
    }
    
    var onSubmit: Bool {
        get {
            if ctrl is cmyTextfield {
                return (ctrl as! cmyTextfield).onsubmit
            } else if ctrl is cmyCustomCheckbox {
                return (ctrl as! cmyCustomCheckbox).onsubmit
            } else {
                return false
            }
        }
        set (submit) {
            if  ctrl is cmyTextfield {
                (ctrl as! cmyTextfield).onsubmit = submit
            }
        }
    }
    
    var identifier: String {
        get {
            return (ctrl.identifier?.rawValue)!
        }
        set (S) {
            ctrl.identifier = NSUserInterfaceItemIdentifier(rawValue: S)
        }
    }
    
    var stringValue: String {
        get {
            if ctrl is cmyTextfield {
                return (ctrl as! cmyTextfield).stringValue
            }
            else
            if ctrl is cmyCombo {
                return (ctrl as! cmyCombo).stringValue
            }
            else if ctrl is cmyCustomCheckbox {
                return (ctrl as! cmyCustomCheckbox).stringValue
            }
            else {
                return ""
            }
        }
        set (S) {
            if ctrl is cmyTextfield {
                (ctrl as! cmyTextfield).stringValue = S
            }
            else
            if ctrl is cmyCombo {
                (ctrl as! cmyCombo).stringValue = S
            }
            else
            if ctrl is NSTextField { // pour les labels
                (ctrl as! NSTextField).stringValue = S
            }
        }
    }
    
    var controller: NSResponder {
        get {
            return parent.myController
        }
    }
    
    var controllerState: etatWindow?{
        get {
            if controller is cbaseController {
                return (controller as! cbaseController).state
            }
            else
            if controller is cbaseView {
                return (controller as! cbaseView).state
            }
            else {
                return .nonedition
            }
        }
    }
    
    var window: NSResponder? {
        get {
            if controller is cbaseController {
                return (controller as! cbaseController).window!
            }
            else
            if controller is cbaseView {
                return (controller as! cbaseView).view
            }
            else {
                return nil
            }
        }
    }
    
    func _init () {
        if isLabel == false {
            if ctrl is NSTextField {
                isLabel = (ctrl as! NSTextField).isSelectable == false && (ctrl as! NSTextField).isEditable == false
            }
        }
        
        if tableView != nil {
            var frame = ctrl.frame
            if ctrl is cmyCombo {
                frame.origin.y = 2
            } else {
                frame.origin.y = 4
                frame.size.height = 24
            }
            ctrl.frame = frame
        }
        if (ctrl.superview?.superview is NSBox) {
            boxView = ctrl.superview?.superview as! NSBox
            if boxView is cmyBox {
                (boxView as! cmyBox).addControl(self)
            }
        }
        
        if ctrl is cmyTextfield {
            (ctrl as! cmyTextfield).parent = self
        } else if ctrl is cmyCombo {
            (ctrl as! cmyCombo).parent = self
        } else if ctrl is cmyCheckbox {
            (ctrl as! cmyCheckbox).parent = self
        }else if ctrl is cmyCustomCheckbox {
            (ctrl as! cmyCustomCheckbox).parent = self
        }
        else if ctrl is NSTabView {
            for i in 0...(ctrl as! NSTabView).tabViewItems.count-1 {
                let item = (ctrl as! NSTabView).tabViewItems[i]
                if item is cmyTabviewItem {
                    (item as! cmyTabviewItem).parent = self
                }
            }
        } else if ctrl is cmyTable {
            (ctrl as! cmyTable).parent = self
            (ctrl as! cmyTable).setBoutonsAttaches()
        }
        
        var nomMethode: String = "load"
        var methode = Selector(nomMethode)
        if  ctrl.responds(to: methode) {
            ctrl.perform(methode)
        } else {
            nomMethode =  "load"+(ctrl.identifier?.rawValue.capitalized)!+"WithCtrl:"
            methode = Selector(nomMethode)
            if controller.responds (to: methode) {
                //controller.perform(methode)
                controller.perform(methode, with:self)
            }
        }
        
        nomMethode = "verif"+(ctrl.identifier?.rawValue.capitalized)!+"WithCtrl:"
        methode = Selector(nomMethode)
        if controller.responds (to: methode) {
            verifControlMethod = methode
        }
        
        nomMethode = "acceptkey"+(ctrl.identifier?.rawValue.capitalized)!+"WithCtrl:event:"
        methode = Selector(nomMethode)
        if controller.responds (to: methode) {
            acceptKeyMethod = methode
        }
        
        nomMethode = "nextfocus"+(ctrl.identifier?.rawValue.capitalized)!+"WithCtrl:"
        methode = Selector(nomMethode)
        if controller.responds (to: methode) {
            nextFocusControl = methode
        }
        
        nomMethode = "getfocus"+identifier.capitalized+"WithCtrl:"
        methode = Selector(nomMethode)
        if controller.responds (to: methode) {
            getfocusMethod = methode
        }
        
        nomMethode = "textcolor"+identifier.capitalized+"WithCtrl:"
        methode = Selector(nomMethode)
        if controller.responds (to: methode) {
            textColorMethod = methode
        }
        
        if ctrl is cmyCustomCheckbox {
            nomMethode = "click"+identifier.capitalized+"WithCtrl:"
            methode = Selector(nomMethode)
            if controller.responds (to: methode) {
                (ctrl as! cmyCustomCheckbox).clickMethod = methode
            }
        }
    }
    
    init (_ aCtrl: NSView, aParent: clisteControles, aTabview: NSTabViewItem!) {
        ctrl = aCtrl
        parent = aParent
        super.init()
        tabviewItem = aTabview
        _init()
        
    }
    
    init (_ aCtrl: NSView, aParent: clisteControles, aTableview: NSTableView) {
        ctrl = aCtrl
        parent = aParent
        //isLabel = false
        super.init()
        tableView = aTableview
        _init()

    }
    
    func makeFirstResponder() {
        ctrl.window?.makeFirstResponder(ctrl)
    }
    
    func setState (state: etatWindow) {
        if ctrl is cmyTable {
            //if state == .nonedition {
            //    (ctrl as! NSTableView).selectionHighlightStyle = .regular
            //} else {
            //    (ctrl as! NSTableView).selectionHighlightStyle = .none
            //}
            (ctrl as! cmyTable).setState(etat: state)
            etat = state
        }
        else
        if isLabel == false {
            etat = state
            if isFiltre {
                if state == .nonedition {
                    isSelectable = ctrl is cmyTable ? false : true
                    isBezeled = true
                    isEditable = ctrl is cmyTable ? false : true
                } else {
                    isSelectable = ctrl is cmyTable ? true : false
                    isBezeled = false
                    isEditable = ctrl is cmyTable ? true: false
                }
            } else {
                if state == .nonedition {
                    if tableView != nil && ctrl is cmyCombo && (ctrl as! cmyCombo).txtassocie != nil {
                        (ctrl as! cmyCombo).isHidden = true
                        (ctrl as! cmyCombo).txtassocie.isHidden = false
                    } else if tableView != nil && ctrl is cmyCustomCheckbox && (ctrl as! cmyCustomCheckbox).txtassocie != nil {
                        (ctrl as! cmyCustomCheckbox).isHidden = true
                        (ctrl as! cmyCustomCheckbox).txtassocie.isHidden = false
                    } else {
                        isSelectable = ctrl is cmyTable ? true : false
                        isBezeled = false
                        isEditable = ctrl is cmyTable ? true: false
                    }
                } else {
                    if tableView != nil && ctrl is cmyCombo && (ctrl as! cmyCombo).txtassocie != nil {
                        (ctrl as! cmyCombo).txtassocie.isHidden = true
                        (ctrl as! cmyCombo).isHidden = false
                        (ctrl as! cmyCombo).stringValue = (ctrl as! cmyCombo).txtassocie.stringValue
                    } else if tableView != nil && ctrl is cmyCustomCheckbox && (ctrl as! cmyCustomCheckbox).txtassocie != nil {
                        (ctrl as! cmyCustomCheckbox).txtassocie.isHidden = true
                        (ctrl as! cmyCustomCheckbox).isHidden = false
                        (ctrl as! cmyCustomCheckbox).stringValue = (ctrl as! cmyCustomCheckbox).txtassocie.stringValue
                    } else {
                        isSelectable = ctrl is cmyTable ? false : true
                        isBezeled = true
                        isEditable = ctrl is cmyTable ? false : true
                    }
                }
            }
        }
    }
    
    func input (_ aValue: String) {
        if ctrl is cmyCombo {
            (ctrl as! cmyCombo).input(aValue)
        }
        else if ctrl is cmyTextfield {
            (ctrl as! cmyTextfield).stringValue = aValue
        }
        else if ctrl is cmyCustomCheckbox {
            (ctrl as! cmyCustomCheckbox).stringValue = aValue
        }
        else if ctrl is cmyCheckbox {
            (ctrl as! cmyCheckbox).stringValue = aValue
        }
    }
    
    func input (donnees: [String: String]) {
        if ctrl is cmyTextfieldAdresse {
            (ctrl as! cmyTextfieldAdresse).input(donnees)
        }
    }
    
    func output(_ donnees: [String: String]) ->Any {
        if ctrl is cmyTable {
            return (ctrl as! cmyTable).output()
        }
        else
        if ctrl is cmyCombo {
            return (ctrl as! cmyCombo).getKey(selection: (ctrl as! cmyCombo).getIndex(valeur: (ctrl as! cmyCombo).stringValue))
        }
        else
        if ctrl is cmyTextfieldDate {
            return cDates((ctrl as! cmyTextfieldDate).stringValue).toSQL()
        }
        else
        if ctrl is cmyCustomCheckbox {
            return (ctrl as! cmyCustomCheckbox).stringValue
        }
        else
        if ctrl is cmyTextfieldAdresse {
            var res: [String: String] = [:]
            res["adresse"] = (ctrl as! cmyTextfieldAdresse).stringValue
            res["cpost"] = (ctrl as! cmyTextfieldAdresse).cpost
            res["ville"] = (ctrl as! cmyTextfieldAdresse).ville
            return res
        }
        else
        if ctrl is cmyCheckbox {
            return (ctrl as! cmyCheckbox).stringValue
        }
        else if ctrl is cmyTextfield {
            return (ctrl as! cmyTextfield).stringValue
        } else {
            return ""
        }
    }
    
    func setDatasource (_ aSource: [String]) {
        if !(ctrl is NSComboBox) {
            Swift.print ("setDatasource ne peut -être utilisé que sur une NSCombobox (\(ctrl.description))")
        }
        var index = 0
        source = []
        while index < aSource.count {
            source = source + [myNewOption(key: aSource[index], value: aSource[index+1])]
            index += 2
        }
        
        (ctrl as! NSComboBox).usesDataSource = true
        (ctrl as! NSComboBox).dataSource = controller as? NSComboBoxDataSource
    }
    
    func enterReceived (_ event: NSEvent) {
    }
    
    func escapeReceived (_ event: NSEvent) {

    }
    
    func controlEnterRecu() {
        if ctrl is cmyTextfield {
            (ctrl as! cmyTextfield).controlEnterRecu()
        }
    }
    
    func popover (_ msg: String) {
        if controller is cbaseController {
            (controller as! cbaseController).showPopover(aControl: ctrl as! NSControl, msg: msg)
        }
        else if controller is cbaseView {
            (controller as! cbaseView).showPopover(aControl: ctrl as! NSControl, msg: msg)
        }
    }
    
    func popover (aController: NSViewController) {
        if controller is cbaseController {
            (controller as! cbaseController).showPopover(aControl: ctrl as! NSControl, controller: aController)
        }
        else if controller is cbaseView {
            (controller as! cbaseView).showPopover(aControl: ctrl as! NSControl, controller: aController)
        }
    }
    
    func verifControl() ->Bool {
        if ctrl is cmyTextfield  {
            if !(ctrl as! cmyTextfield).verifObligatoire() {
                popover("Zone obligatoire")
                return false
            }
            if (!(ctrl as! cmyTextfield).verifCoherence()) {
                return false
            }
        }
        else
        if ctrl is cmyCombo {
            if !(ctrl as! cmyCombo).verifObligatoire() {
                popover("Zone obligatoire")
                return false
            }
        }
        if verifControlMethod != nil {
            let res = controller.perform(verifControlMethod, with: ctrl as! NSControl)
            if res == nil {
                return false
            }
            let bRes = Unmanaged<AnyObject>.fromOpaque(
                res!.toOpaque()).takeUnretainedValue()
            return (bRes as! NSNumber).intValue == 1 ? true : false
        } else {
            return true
        }
    }
    
    
    func acceptKey (event: NSEvent) -> Bool {
        if acceptKeyMethod != nil {
            let res = controller.perform(acceptKeyMethod, with: ctrl as! NSControl, with: event)
            if res == nil {
                return false
            }
            let bRes = Unmanaged<AnyObject>.fromOpaque(
                res!.toOpaque()).takeUnretainedValue()
            return (bRes as! NSNumber).intValue == 1 ? true : false
        } else if ctrl is cmyTextfield {
            return (ctrl as! cmyTextfield).acceptKey(event: event)
        } else if ctrl is cmyCombo {
            if [ckeyboardKeys.downArrow, ckeyboardKeys.upArrow].contains(event.keyCode) {
                return true
            }
            var S: String? = (ctrl as! cmyCombo).stringValue
            S = (ctrl as! cmyCombo).completedString(S!)
            if S != nil {
                (ctrl as! cmyCombo).stringValue = S!
            }
            return true
        } else {
            return true
        }
    }
}

//MARK: mySelectorProtocol
extension cmyControl: mySelectorProtocol {
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

open class cmyTextfieldDoc: cmyTextfield {
    var document: String!
    var directory: String!
    var trackingArea: NSTrackingArea?
    var suffixe: String = ""
    
    override open var acceptsFirstResponder: Bool {return false}
    
    func input (_ donnees: [String: String]) {
        if donnees.keys.contains((self.identifier?.rawValue)!) {
            //let document: String = "document" + (!suffixe.isEmpty ? suffixe : "")
            //let directory: String = "repertoire" + (!suffixe.isEmpty ? suffixe : "")
            self.stringValue = donnees["document"]!
        }
    }
    
    override open func mouseEntered(with event: NSEvent) {
        Swift.print("\(String(describing: self.identifier)) Mouse entered")
    }
    
    override open func mouseExited(with event: NSEvent) {
        Swift.print("\(String(describing: self.identifier)) Mouse exited")
    }
    
    override open func mouseDown(with event: NSEvent) {
        Swift.print("\(String(describing: self.identifier)) Mouse down")
        let repertoire = "/users/patricerapaport/Sites/compta1/Documents/"+directory+"/"+document
        Swift.print("\(repertoire)")
        //var dir: UnsafeMutablePointer<ObjCBool>!
        let manager = FileManager.default
        var bRes = manager.isReadableFile(atPath: repertoire)
        let workSpace =  NSWorkspace.shared
        bRes = workSpace.openFile(repertoire)
    }
}

@IBDesignable class myNewCheckControl: cmyTextfield {
    override init(frame: NSRect) {
        var myRect = frame
        myRect.size.width = 20
        myRect.size.height = 20
        super.init(frame: myRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    @IBInspectable override var frame: NSRect {
        get {
            var aFrame = super.frame
            aFrame.size.height = 20
            aFrame.size.height = 20
            return aFrame
        }
        set (aFrame) {
            var myFrame = aFrame
            myFrame.size.height = 20
            myFrame.size.height = 20
            super.frame = myFrame
            subviews[0].frame = myFrame
            needsDisplay = true
        }
    }
    
    override func layout() {
        super.layout()
        layer?.frame.size.width = 20
        updateLayer()
    }
    
}

