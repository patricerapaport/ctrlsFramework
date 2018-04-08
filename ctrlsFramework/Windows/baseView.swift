//
//  cbaseView.swift
//  testinput
//
//  Created by Patrice Rapaport on 18/10/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class cbaseView: NSViewController, myBaseServiceTabview {
    var ctrls: clisteControles!
    var donnees: [String: String] = [:]
    var tabView: NSTabView!
    var tabviewSelected: NSTabViewItem!
    var boutonsToolbar: [cmyToolbarItem]!
    var currentFocus: cmyControl!
    var state: etatWindow = .nonedition
    var myPopover: NSPopover!
    var popoverViewController: NSViewController!
    var tableCourante: cmyControl!  // contient le nom de la dernière table recherchée pour éviter d'appeler 36 fois getControl
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let content: NSView = view
        setControls(view: content, tabviewItem: nil)
        setState(etat: .nonedition)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // should Close recu: on retire les window connexes
    func windowShouldClose(_ sender: Any) -> Bool {
        if view.window?.toolbar != nil && boutonsToolbar != nil { // si la fonction a déjà été appelée boutonsToolbar se retrouve à nil
            viderToolbar()
            for bt in boutonsToolbar {
                self.view.window?.toolbar?.insertItem(withItemIdentifier: bt.itemIdentifier, at: 0)
            }
            
            boutonsToolbar = nil
            fermetureAnnexes()
        }
        
        return true
    }
    
    // Cette méthode doit être surchargée pour refermer les fenêtres connexes
    func fermetureAnnexes() {
    }
    
    // ajouter les boutons de la toolbar
    func setToolbar () {
        boutonsToolbar = []
        for item in (view.window?.toolbar?.items)! {
            if item is cmyToolbarItem {
                (item as! cmyToolbarItem)._init()
                boutonsToolbar.append(item as! cmyToolbarItem)
            }
        }
    }
    
    func btToolbar (_ type: cmyTypesBoutons) -> cmyToolbarItem? {
        for bt in boutonsToolbar {
            if bt.typeBouton == type {
                return bt
            }
        }
        return nil
    }

    // construit la liste des controles
    func setControls (view: NSView, tabviewItem: NSTabViewItem?) {
        if ctrls == nil {
            ctrls = clisteControles (aController: self)
        }
        for control in view.subviews {
            if control is NSScrollView || control is NSClipView {
                setControls(view: control, tabviewItem: tabviewItem)
                continue
            }
            else
                if control is NSBox  {
                    let boxView: NSBox = control as! NSBox
                    setControls(view: boxView.contentView!, tabviewItem: tabviewItem)
                    continue
                }
                else
                    if control is NSTabView  {
                        (control as! NSTabView).delegate = self
                        self.tabView = control as! NSTabView
                        ctrls.append(tabview: control as! NSTabView, tabviewitem: tabviewItem)
                        for i in 0...self.tabView.numberOfTabViewItems-1 {
                            setControls(view: self.tabView.tabViewItem(at: i).view!, tabviewItem: self.tabView.tabViewItem(at: i))
                        }
                        continue
                    }
                    else
                        if control is cmyCustomCheckbox {
                            ctrls.append(aView: control, tabviewitem: tabviewItem)
                            continue
            }
            if !(control is NSScrollView) && !(control is NSClipView) {
                if control.identifier != nil && control.identifier?.rawValue.substr(from: 0, to: 3) == "_NS:" {
                    if !(control is cmyTable) &&
                        !(control is cmyCheckbox) &&
                        !(control is cmyTextfieldAdresse) {
                        continue
                    }
                }
            }
            
            if control is NSControl {
                if control.identifier?.rawValue.substr(from: 0, to: 4) == "_NS:" {
                    if !(control is cmyTable) &&
                        !(control is cmyCheckbox) &&
                        !(control is cmyTextfieldAdresse
                        ) {
                        continue
                    }
                }
                ctrls.append(ctrl: control as! NSControl, tabviewitem: tabviewItem)
            }
            if control is NSTableView {
                if control is cmyTable {
                    (control as! cmyTable).state = .nonedition
                }
                (control as! NSTableView).delegate = self
                (control as! NSTableView).dataSource = self
            }
            
            if (control is NSTextField && (control as! NSTextField).delegate == nil) {
                (control as! NSTextField).delegate = self
            }
            
        }
    }
    
    func getControl (_ identifier: String) -> cmyControl? {
        if ctrls == nil {
            return nil
        }
        return ctrls.getControl(identifier)
    }
    
    // Passe en mode edition ou nonedition
    func setState (etat: etatWindow) {
        if ctrls != nil {
            ctrls.setState(state: etat)
        }
        state = etat
        
        if (boutonsToolbar != nil && boutonsToolbar.count > 0) {
            var itemTrouve = false
            let toolbar: NSToolbar = (view.window?.toolbar)!
            if toolbar.items.count > 0 && toolbar.selectedItemIdentifier != nil {
                for item in toolbar.items {
                    if item.itemIdentifier == toolbar.selectedItemIdentifier {
                        let identifier = toolbar.selectedItemIdentifier
                        let nomMethode: String =  "select"+identifier!.rawValue.capitalized+"WithCtrl:"
                        let methode = Selector(nomMethode)
                        if self.responds (to: methode) {
                            //controller.perform(methode)
                            self.perform(methode, with:item)
                            itemTrouve = true
                            break
                        }
                    }
                }
            }
            if !itemTrouve {
                viderToolbar()
                for i in 0...boutonsToolbar.count-1 {
                    boutonsToolbar[i].setState(controller: self, etat: etat)
                }
            }
        }
        if state == .nonedition {
            view.window?.makeFirstResponder(nil)
        }
        else {
            for control in ctrls.controles {
                if control.ctrl is NSTabView {
                    continue
                }
                if tabviewSelected != nil && control.tabviewItem != nil && control.tabviewItem == tabviewSelected {
                    view.window?.makeFirstResponder(control.ctrl)
                    break
                } else {
                    if tabviewSelected == nil && control.tabviewItem == nil {
                        view.window?.makeFirstResponder(control.ctrl)
                        break
                    }
                }
            }
        }
    }

    func input() {
        input(theDonnees: donnees, item: nil)
    }
    
    func input (item: NSTabViewItem) {
        input(theDonnees: donnees, item: item)
    }
    
    func input (theDonnees: [String: String], item: NSTabViewItem!) {
        if theDonnees.count > 0 && ctrls != nil {
            ctrls.input(theDonnees, item: item)
        }
    }
    
    func output() {
        donnees = ctrls.output()
    }
    
    func createPopover (_ aController: NSViewController!) {
        if myPopover == nil {
            // create and setup our popover
            myPopover = NSPopover()
            
            // the popover retains us and we retain the popover,
            // we drop the popover whenever it is closed to avoid a cycle
            if aController == nil {
                popoverViewController = popoverController()
                myPopover.contentViewController = popoverViewController
            } else {
                myPopover.contentViewController = aController
            }
            
            //myPopover.appearance = NSAppearance.Name.vibrantLight
            
            //myPopover.animates = (self.animatesCheckbox).state;
            
            // AppKit will close the popover when the user interacts with a user interface element outside the popover.
            // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
            myPopover.behavior = NSPopover.Behavior.transient;
            
            // so we can be notified when the popover appears or closes
            myPopover.delegate = self;
        }
    }
    
    func showPopover (aControl: NSControl, msg: String) {
        createPopover(nil)
        myPopover.show(relativeTo: aControl.bounds, of: aControl, preferredEdge: NSRectEdge(rawValue: 0)!)
        let frame = (myPopover.contentViewController as! popoverController).setLabel(msg: msg)
        myPopover.contentSize = frame.size
    }
    
    func showPopover (aControl: NSControl, controller: NSViewController) {
        createPopover(controller)
        myPopover.show(relativeTo: aControl.bounds, of: aControl, preferredEdge: NSRectEdge(rawValue: 0)!)
        //let frame = (myPopover.contentViewController as! popoverController).setLabel(msg: msg)
        //myPopover.contentSize = frame.size
    }
    
    // Cette fonction doit être surchargée pour définir les actions à entreprendre quand une rangée est sélectionnée
    func selected(_ tbl: cmyTable) {
    }
    
    // Cette fonction doit -etre surchargée pour trier la tableview
    func trierTable (_ tbl: cmyTable, column: cmyColumn) {
    }
}

// MARK: opérations
extension cbaseView {
    @objc func Modifier(_ sender: Any) {
        setState(etat: .edition)
    }
    
    @objc func Ajouter(_ sender: Any) {
        setState(etat: .ajout)
    }
    
    @objc func Supprimer(_ sender: Any) {
    }
    
    @objc func Annuler(_ sender: Any) {
        if myPopover != nil && myPopover.isShown {
            myPopover.close()
        }
        input()
        setState(etat: .nonedition)
    }
    
    @objc func Save (_ sender: Any) -> Bool {
        if myPopover != nil && myPopover.isShown {
            myPopover.close()
        }
        if ctrls.verifControl() {
            output()
            //if self is ceditWindow {
            //    (self as! ceditWindow).transformDonnees()
            //}
            setState(etat: .nonedition)
            return true
        } else {
            return false
        }
    }
}

extension cbaseView: NSPopoverDelegate {
    
}

// MARK: NSTextFieldDelegate
extension cbaseView : NSTextFieldDelegate {
    override open func controlTextDidBeginEditing(_ obj: Notification) {
        Swift.print("didbeginediting")
    }
}

// MARK: gestion tabview
extension cbaseView {
    func setConfigs() {
        
    }
    
    func viderToolbar() {
        let toolbar: NSToolbar? = (view.window?.toolbar)!
        if toolbar != nil {
            var index: Int = toolbar!.items.count-1
            while (index > -1) {
                toolbar?.removeItem(at: index)
                index -= 1
            }
        }
    }
    
    func shouldSelect (tabviewItem: NSTabViewItem) -> Bool {
        return true
    }
    
    func didSelect (tabViewItem: NSTabViewItem) {
        tabviewSelected = tabViewItem
    }
    
    // faut-il vider la toolbar quand on sélectionne un autre onglet
    func emptyToolbarWhileChanging (from: NSTabViewItem, to: NSTabViewItem) -> Bool {
        return true
    }
}

//MARK: NSTabVieDelegate
extension cbaseView: NSTabViewDelegate {
    public func tabView(_ tabView: NSTabView, shouldSelect tabViewItem: NSTabViewItem?) -> Bool {
        var bRes = false
        if !shouldSelect (tabviewItem: tabViewItem!) {
            return false
        }
        if tabViewItem is cmyTabviewItem {
            bRes =  (tabViewItem as! cmyTabviewItem).shouldSelect()
        } else {
            bRes = true
        }
        if bRes {
            tabviewSelected = tabView.selectedTabViewItem!
        }
        return bRes
    }
    
    public func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        let title = tabViewItem?.identifier as! String
        if state == .nonedition {
            if emptyToolbarWhileChanging(from: tabviewSelected, to: tabViewItem!) {
                viderToolbar()
            }
        }
        didSelect (tabViewItem: tabViewItem!)
        let nomMethode: String =  "select"+title.capitalized+"WithCtrl:"
        let methode = Selector(nomMethode)
        if self.responds (to: methode) {
            //controller.perform(methode)
            self.perform(methode, with:tabViewItem)
        }
    }
}

extension cbaseView : NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        var source: crowsTable!
        if tableCourante == nil || tableCourante.identifier != tableView.identifier?.rawValue {
            tableCourante = getControl((tableView.identifier?.rawValue)!)
        }
        if tableCourante?.ctrl is NSTableView {
            source = tableCourante?.datasource
        }
        if (source != nil) {
            return source!.count()
        } else {
            return 0
        }
    }
}
extension cbaseView: NSTableViewDelegate {
    public func tableViewSelectionDidChange(_ notification: Notification) {
        selected(notification.object as! cmyTable)
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        var source: crowsTable!
        
        if tableCourante == nil || tableCourante.identifier != tableView.identifier?.rawValue {
            tableCourante = getControl((tableView.identifier?.rawValue)!)
        }
        let control = tableCourante
        if control?.ctrl is NSTableView {
            source = control?.datasource
        } else {
            return nil
        }
        
        guard let item = source?.item(row: row) else {
            return nil
        }
        
        var index = 0
        var textColor: NSColor?
        while (index <= tableView.tableColumns.count) {
            if (tableColumn == tableView.tableColumns[index]) {
                text = item.valeur(identifier: (tableColumn?.identifier.rawValue)!, interpreted: true) as! String
                textColor = item.textColor(identifier: (tableColumn?.identifier.rawValue)!)
                cellIdentifier = (tableColumn?.identifier.rawValue)!
                break
            }
            index += 1
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            if textColor != nil {
                cell.textField?.textColor = textColor
            }
            if (cellIdentifier == "nbdocs") {
                for bt in cell.subviews {
                    if bt is cmyControlDoc {
                        let nomMethode: String = "get"+tableColumn!.identifier.rawValue.capitalized+":donnees:"
                        let methode = Selector(nomMethode)
                        if self.responds (to: methode) {
                            self.perform(methode, with: bt, with: item.donnees)
                        }
                        //(bt as! myControlDoc).title = text
                        text = ""
                    }
                    else
                        if bt is cmyCombo {
                            
                    }
                }
            }
            if cell.subviews[0] is cmyCombo {
                (cell.subviews[0] as! cmyCombo).stringValue = text
            } else {
                cell.textField?.stringValue = text
            }
            //cell.toolTip = "Tooltip sur la cellule"
            //cell.addToolTip(<#T##rect: NSRect##NSRect#>, owner: <#T##Any#>, userData: <#T##UnsafeMutableRawPointer?#>)
            return cell
        }
        return nil
    }
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        Swift.print("click sur \(tableColumn.description)")
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        if tableColumn is cmyColumn && (tableColumn as! cmyColumn).isSortable {
            trierTable(tableView as! cmyTable, column: tableColumn as! cmyColumn)
        }
        return false
    }
    
    public func tableView(_ tableView: NSTableView, shouldTrackCell cell: NSCell, for tableColumn: NSTableColumn?, row: Int) -> Bool {
        Swift.print("tarckcell sur \(String(describing: tableColumn?.description))")
        return false
    }
    
    public func tableView(_ tableView: NSTableView, shouldShowCellExpansionFor tableColumn: NSTableColumn?, row: Int) -> Bool {
        Swift.print("tooltip sur \(String(describing: tableColumn?.description))")
        return false
    }
    
    public func tableView(_ tableView: NSTableView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
        Swift.print("tooltip sur \(cell.description)")
        return ""
    }
    
    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if tableCourante == nil || tableCourante.identifier != tableView.identifier?.rawValue {
            tableCourante = getControl((tableView.identifier?.rawValue)!)
        }
        let aRow =  tableView.rowView (atRow: row, makeIfNecessary: false)
        return aRow == nil ? nil : aRow
    }
    
    public func tableViewSelectionIsChanging(_ notification: Notification) {
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView is cmyTable {
            (tableView as! cmyTable).rowselected = row
        }
        return true
    }
}
