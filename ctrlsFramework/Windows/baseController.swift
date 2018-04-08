        //
//  cbaseController.swift
//  testinput
//
//  Created by Patrice Rapaport on 15/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

enum etatWindow {
    case nonedition
    case edition
    case ajout
}
        
var activesWindow: [NSWindowController] = []
let preferenceManager = PreferenceManager()

// MARK: ProtocolOperations
protocol myBaseServiceProtocolOperations {
    func Modifier(_ sender: Any)
    func Ajouter(_ sender: Any)
    func Supprimer(_ sender: Any)
    func Annuler(_ sender: Any)
    func Save (_ sender: Any) -> Bool
}

protocol myBaseServiceTabview {
    //@objc func setConfigs()
    func emptyToolbarWhileChanging (from: NSTabViewItem, to: NSTabViewItem) -> Bool
    func viderToolbar()
    func shouldSelect (tabviewItem: NSTabViewItem) -> Bool
    func didSelect (tabViewItem: NSTabViewItem)
}

//MARK:  cbaseController
open class cbaseController: NSWindowController, myBaseServiceProtocolOperations, myBaseServiceTabview {
    
    var ctrls: clisteControles!
    var tabView: NSTabView!
    var tabviewSelected: NSTabViewItem!
    var state: etatWindow = .nonedition
    var donnees: [String: String] = [:]
    var boutonsToolbar: [cmyToolbarItem]!
    var currentFocus: cmyControl!
    var myPopover: NSPopover!
    var popoverViewController: NSViewController!          // Popover pour afficher une liste de documents
    var docPopoverController: documentPopoverController!
    var documentPopover: NSPopover!
    var timerDocument: Timer!
    var indicator: NSProgressIndicator!
    var internalSetFrame: Bool = false // A activer si l'on redimensionne la fenêtre et que l'on ne veut pas recevoir une notification resize
    var tableCourante: cmyControl!  // contient le nom de la dernière table recherchée pour éviter d'appeler 36 fois getControl
    
    override open var windowNibName: NSNib.Name? {
        let els = className.components(separatedBy: ".")
        if els.count > 1 {
            return NSNib.Name(els[1])
        } else {
            return NSNib.Name(els[0])
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder:coder)
    }

    override init(window: NSWindow?) {
        super.init(window: window)
    }
    
    override open func windowDidLoad() {
        super.windowDidLoad()
        
        windowFrameAutosaveName = (windowNibName!.rawValue as NSString) as NSWindow.FrameAutosaveName
        window?.setFrameUsingName(windowFrameAutosaveName)
        
        if (window is cmyWindow) {
            (window as! cmyWindow).controller = self
        }
    
        if isInActivesWindow() == -1 {
            activesWindow.append(self)
        }
        if window?.toolbar != nil {
            setToolbar()
        }
        
        indicator = NSProgressIndicator()
        window?.contentView?.addSubview(indicator)
        indicator.frame.origin.x = (window?.frame.size.width)! / 2
        indicator.frame.origin.y = (window?.frame.size.height)! / 2
        indicator.frame.size.width = 40
        indicator.frame.size.height = 40
        indicator.style = .spinning
        indicator.isIndeterminate = true
        indicator.isHidden = false
        indicator.isDisplayedWhenStopped = false
        
        setState(etat: .nonedition)
    }

    
    init() {
        super.init(window: nil)
        register()
        let content: NSView = (window?.contentView)!
        //if (window is clWindow) {
        //    (window as! clWindow).myController = self
        //}
        
        //ctrls = myControles()
        
        setControls(view: content, tabviewItem: nil)

        
        
        
        setConfigs()
        setState(etat: .nonedition)
    }
    
    // Enregistrement dans la liste des fenêtres actives
    func register () {
        if isInActivesWindow() == -1 {
            activesWindow.append(self)
        }
    }
    
    // Cette fonction doit être surchargée pour effectuer un nettoyage personnalisé de la fenêtre. Elle est appelée par shouldClose de NSWindowDelegate
    func closeWindow() {
        if window?.toolbar != nil && boutonsToolbar != nil { // si la fonction a déjà été appelée boutonsToolbar se retrouve à nil
            viderToolbar()
            for bt in boutonsToolbar {
                self.window?.toolbar?.insertItem(withItemIdentifier: bt.itemIdentifier, at: 0)
            }
            
            boutonsToolbar = nil
            fermetureAnnexes()
        }
        
        ctrls = nil
        let index = isInActivesWindow()
        if index != -1 {
            activesWindow.remove(at: index)
        }
    }
    
    // Cette méthode doit être surchargée pour refermer les fenêtres connexes
    func fermetureAnnexes() {
    }
    
    // recherche l'index dans activesWindow
    func isInActivesWindow () ->Int {
        if activesWindow.contains(self) {
            return activesWindow.index(of: self)!
        } else {
            return -1
        }
    }
    
    func refreshDoc (iddocument: Int) { // A surcharger pour rafraichir le document
    }
    
    func refreshDoc (id: Int, nomsociete: String, repertoire: String, document: String, nbdocs: String) { // A surcharger pour raftaichir une liste de documents
    }
    
    func typeserver() ->String {
        let server = preferenceManager.wsServerType
        switch server {
            case serverType.local: return "Serveur local"
            case serverType.distant: return "Serveur distant"
            default: return "Serveur inconnu"
        }
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
                popoverViewController = popoverController()
                //popoverViewController.childViewControllers.append(aController)
                myPopover.contentViewController = aController
                //myPopover.contentViewController = popoverViewController
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
    
    // ajouter les boutons de la toolbar
    func setToolbar () {
        boutonsToolbar = []
        for item in (window?.toolbar?.items)! {
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
                if boxView.contentView != nil {
                    setControls(view: boxView.contentView!, tabviewItem: tabviewItem)
                }
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
                //setConfigs()
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
                        !(control is cmyTextfieldAdresse) &&
                        (!(control is cmyTextfield) || !(control as! cmyTextfield).isFiltre){
                        continue
                    }
                }
            }
            
            if control is NSControl {
                if control.identifier?.rawValue.substr(from: 0, to: 4) == "_NS:" {
                    if !(control is cmyTable) &&
                    !(control is cmyCheckbox) &&
                    !(control is cmyTextfieldAdresse) {
                        continue
                    }
                }
                if control is NSComboBox {
                    (control as! NSComboBox).delegate = self
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
            let toolbar: NSToolbar = (window?.toolbar)!
            if toolbar.items.count > 0 && toolbar.selectedItemIdentifier != nil {
                for item in toolbar.items {
                    if item.itemIdentifier == toolbar.selectedItemIdentifier {
                        let nomMethode: String =  "select"+toolbar.selectedItemIdentifier!.rawValue.capitalized+"WithCtrl:"
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
                var index = 0
                for i in 0...boutonsToolbar.count-1 {
                    if boutonsToolbar[i].insertInToolbar (controller: self, etat: etat, index: index) {
                        index = index + 1
                    }
                }
            }
        }
        if state == .nonedition {
            window?.makeFirstResponder(nil)
        }
        else {
            for control in ctrls.controles {
                if control.ctrl is NSTabView {
                    continue
                }
                if tabviewSelected != nil && control.tabviewItem != nil && control.tabviewItem == tabviewSelected && control.isEditable {
                    window?.makeFirstResponder(control.ctrl)
                    break
                } else {
                    if tabviewSelected == nil && control.tabviewItem == nil && control.isEditable {
                        window?.makeFirstResponder(control.ctrl)
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
    
    // Cette fonction doit être surchargée pour définir les actions à entreprendre quand une rangée est sélectionnée
    func selected(_ tbl: cmyTable) {
    }
    
    // Cette fonction doit -etre surchargée pour trier la tableview
    func trierTable (_ tbl: cmyTable, column: cmyColumn) {
    }
}
        
// MARK: documents
extension cbaseController {
    override open func mouseEntered(with event: NSEvent) {
        if let userData = event.trackingArea?.userInfo as? [String : String] {
            let aRect = NSRect(x: event.locationInWindow.x, y: event.locationInWindow.y, width: 100, height: 100)
            if userData.keys.contains("nbdocs") {
                showDocumentPopover(aFrame: aRect, idcle: userData["id"]!, idtypedocument: userData["idtypedocument"]!)
            }
        }
        
    }
    
    override open func mouseExited(with event: NSEvent) {
        if documentPopover != nil && documentPopover.isShown {
            timerDocument =  Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(closeDocumentPopover), userInfo: nil, repeats: false)
        }
    }
    
    func createDocumentPopover (_ aController: NSViewController!) {
        if documentPopover == nil {
            // create and setup our popover
            documentPopover = NSPopover()
            
            // the popover retains us and we retain the popover,
            // we drop the popover whenever it is closed to avoid a cycle
            if aController == nil {
                popoverViewController = popoverController()
                myPopover.contentViewController = popoverViewController
            } else {
                popoverViewController = popoverController()
                //popoverViewController.childViewControllers.append(aController)
                documentPopover.contentViewController = aController
                //myPopover.contentViewController = popoverViewController
            }
            
            //myPopover.appearance = NSAppearance.Name.vibrantLight
            
            //myPopover.animates = (self.animatesCheckbox).state;
            
            // AppKit will close the popover when the user interacts with a user interface element outside the popover.
            // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
            documentPopover.behavior = NSPopover.Behavior.transient;
            
            // so we can be notified when the popover appears or closes
            documentPopover.delegate = self;
        }
    }
    
    @objc func closeDocumentPopover() {
        if timerDocument != nil {
            timerDocument.invalidate()
            timerDocument = nil
        }
        documentPopover.close()
    }
    
    func showDocumentPopover (aFrame: NSRect, idcle: String, idtypedocument: String) {
        //let ws = webService(sender: self as! webServiceProtocolDelegate, theCmd: "cmd", theParams: ["nomtable=documents", "idtypedocument="+idtypedocument, "method=listerdocuments", "idcle="+idcle, "idsession="+String(user.idsession)])
        let ws = cwebService()
        var response: [String] = []
        var result: Bool!
        //ws.Send(completion: {
        //    (res, rep) -> Void in
        //    response = rep
        //    result = res
        //})
        if !result {
            let alert = NSAlert()
            alert.informativeText = "Web Service"
            alert.messageText = response[0]
            alert.runModal()
            return
        }
        
        if docPopoverController == nil {
            docPopoverController = documentPopoverController(rows: crowsTable(controller: self, response: response))
        }
        createDocumentPopover(docPopoverController)
        documentPopover.show(relativeTo: aFrame, of: (self.window?.contentView)!, preferredEdge: NSRectEdge(rawValue: 0)!)
        //let frame = docPopoverController.view.setLabel(msg: msg)
        //myPopover.contentSize = frame.size
    }
}

// MARK: gestion tabview
extension cbaseController {
    @objc func setConfigs() { // Cette foncion permet de créer les configurations de la toolbar pour chaque tabviewitem
        // la fonction de base n'est appelée que si la fenêtre comprend une tabview
        if tabView == nil {
            return
        }
        let selected = tabView.selectedTabViewItem
        viderToolbar()
        if selected is cmyTabviewItem &&
            shouldSelect (tabviewItem: selected!) &&
            (selected as! cmyTabviewItem).shouldSelect() {
                tabviewSelected = tabView.selectedTabViewItem!
            
                let title = selected?.identifier as! String
                viderToolbar()
                didSelect (tabViewItem: selected!)
                let nomMethode: String =  "select"+title.capitalized+"WithCtrl:"
                let methode = Selector(nomMethode)
                if self.responds (to: methode) {
                    self.perform(methode, with:selected!)
                }
        }
    }
    
    @objc func viderToolbar() {
        let toolbar: NSToolbar? = (window?.toolbar)!
        if toolbar != nil {
            var index: Int = toolbar!.items.count-1
            while (index > -1) {
                if toolbar?.items[index] is cmyToolbarItem {
                   (toolbar?.items[index] as! cmyToolbarItem).removeFromToolbar()
                }
                toolbar?.removeItem(at: index)
                index -= 1
            }
        }
    }
    
    @objc func shouldSelect (tabviewItem: NSTabViewItem) -> Bool {
        return true
    }
    
    @objc func didSelect (tabViewItem: NSTabViewItem) {
        let title = tabViewItem.identifier as! String
        if state == .nonedition {
            if tabviewSelected != nil {
                if emptyToolbarWhileChanging(from: tabviewSelected, to: tabViewItem) {
                    viderToolbar()
                }
            } else {
                viderToolbar()
            }
            let toolbar: NSToolbar = (window?.toolbar)!
            if toolbar != nil && toolbar.items.count == 0 {
                var index = 0
                for i in 0...boutonsToolbar.count-1 {
                    let bt = boutonsToolbar[i]
                    bt.setConfig(nom: tabViewItem.identifier as! String)
                    if bt.insertInToolbar(controller: self, etat: self.state, index: index) {
                        index = index + 1
                    }
                }
            }
        }
        tabviewSelected = tabViewItem
        let nomMethode: String =  "select"+title.capitalized+"WithCtrl:"
        let methode = Selector(nomMethode)
        if self.responds (to: methode) {
            //controller.perform(methode)
            self.perform(methode, with:tabViewItem)
        }
    }
    
    // faut-il vider la toolbar quand on sélectionne un autre onglet
    @objc func emptyToolbarWhileChanging (from: NSTabViewItem, to: NSTabViewItem) -> Bool {
        return true
    }
}

// MARK: opérations
extension cbaseController {
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
            if self is ceditWindow {
                (self as! ceditWindow).transformDonnees()
            }
            setState(etat: .nonedition)
            return true
        } else {
            return false
        }
    }
    
    @objc func clickdoc (ctrl: cmyControlDoc) {
        ctrl.mouseDown()
    }
}

extension cbaseController: NSPopoverDelegate {
    
}

extension cbaseController : NSTextFieldDelegate {
    override open func controlTextDidBeginEditing(_ obj: Notification) {
        Swift.print("didbeginediting")
    }
}

//MARK: NSComboBoxDataSource
extension cbaseController: NSComboBoxDataSource, NSComboBoxDelegate {
    public func numberOfItems(in comboBox: NSComboBox) -> Int {
        if comboBox is cmyCombo {
            return (comboBox as! cmyCombo).numberOfItems(in: comboBox)
        }
        else {
            return 0
        }
    }
    
    public func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if comboBox is cmyCombo {
            return (comboBox as! cmyCombo).objectValueForItemAt(index)
        } else {
            return ""
        }
    }
    
    public func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        if comboBox is cmyCombo {
            return (comboBox as! cmyCombo).indexOfItemWithStringValue(string)
        } else {
            return -1
        }
    }
    
    public func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        if comboBox is cmyCombo {
            return (comboBox as! cmyCombo).completedString(string)
        } else {
            return nil
        }
    }
    
    public func comboBoxWillPopUp(_ notification: Notification) {
        if state == .nonedition {
            (notification.object as! cmyCombo).isEnabled = false
            return
        } else {
            (notification.object as! cmyCombo).isEnabled = true
        }
    }
    
    public func comboBoxWillDismiss (_ notification: Notification) {
        (notification.object as! cmyCombo).isEnabled = true
    }
    
    public func comboBoxSelectionDidChange(_ notification: Notification) {
        let ctrl : cmyCombo = notification.object as! cmyCombo
        ctrl.selectionDidChange()
    }
}

// MARK: NSTabViewDelegate
extension cbaseController: NSTabViewDelegate {
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
        didSelect (tabViewItem: tabViewItem!)
    }
}

// MARK: NSTableViewDataSource
extension cbaseController : NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
        var source: crowsTable!
        if tableCourante == nil || tableCourante.identifier != tableView.identifier?.rawValue {
            tableCourante = getControl(tableView.identifier!.rawValue)
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

// MARK: NSTableViewDelegate
extension cbaseController: NSTableViewDelegate {
    public func tableViewSelectionDidChange(_ notification: Notification) {
        let tbl = notification.object as! NSTableView

        let toolbar = window?.toolbar
        if toolbar != nil && toolbar?.items.count != 0 {
            if tbl is cmyTable && (tbl as! cmyTable).boutonsAttaches {
                for i in 0...(tbl as! cmyTable).boutonsToolbar.count-1 {
                    (tbl as! cmyTable).boutonsToolbar[i].setEtat(numberOfSelectedRows: tbl.numberOfSelectedRows)
                }
            } else if boutonsToolbar != nil {
                for i in 0...boutonsToolbar.count-1 {
                    boutonsToolbar[i].setEtat(numberOfSelectedRows: tbl.numberOfSelectedRows)
                }
            }
        }
        selected(notification.object as! cmyTable)
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        var source: crowsTable!
        
        if tableCourante == nil || tableCourante.identifier != tableView.identifier?.rawValue {
            tableCourante = getControl(tableView.identifier!.rawValue)
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
                text = item.valeur(identifier: (tableColumn?.identifier)!.rawValue, interpreted: true) as! String
                textColor = item.textColor(identifier: (tableColumn?.identifier)!.rawValue)
                cellIdentifier = (tableColumn?.identifier)!.rawValue
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
                    if item.donnees.keys.contains(cellIdentifier) {
                        if bt is cmyControlDoc {
                            bt.isHidden = false
                            if item.donnees.keys.contains("nomsociete") {
                                if item.donnees.keys.contains("repertoire") {
                                    (bt as! cmyControlDoc).directory = item.donnees["nomsociete"]! + "/" + item.donnees["repertoire"]!
                                } else {
                                    (bt as! cmyControlDoc).directory = item.donnees["nomsociete"]!
                                }
                            }
                            if item.donnees.keys.contains("document") {
                                (bt as! cmyControlDoc).document = item.donnees["document"]!
                            }
                            let nomMethode: String = "get"+tableColumn!.identifier.rawValue.capitalized+":donnees:"
                            let methode = Selector(nomMethode)
                            if self.responds (to: methode) {
                                let res = self.perform(methode, with: bt, with: item.donnees)
                                let szRes = Unmanaged<AnyObject>.fromOpaque(
                                    res!.toOpaque()).takeUnretainedValue()
                                (bt as! cmyControlDoc).title = szRes as! String
                            } else {
                                let nbdocs = item.donnees["nbdocs"]
                                if nbdocs == "0" || nbdocs == "" {
                                    (bt as! cmyControlDoc).title = ""
                                    (bt as! cmyControlDoc).action = nil
                                } else if nbdocs == "1" {
                                    (bt as! cmyControlDoc).title = ""
                                    (bt as! cmyControlDoc).action = #selector(clickdoc(ctrl:))
                                } else {
                                    var rect = tableView.rect(ofRow: row)
                                    rect = tableView.convert(rect, to: window?.contentView)
                                    var aFrame = tableView.convert(cell.frame, to: window?.contentView)
                                    aFrame.origin.y = rect.origin.y
                                    aFrame.size.height = rect.size.height
                                    let trackingArea = NSTrackingArea(rect: aFrame, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: ["id": item.donnees["id"]!, "nbdocs": item.donnees["nbdocs"]!, "idtypedocument": item.donnees["idtypedocument"]!])
                                    window?.contentView?.addTrackingArea(trackingArea)
                                    (bt as! cmyControlDoc).title = ""
                                    (bt as! cmyControlDoc).action = nil
                                }
                                text = (bt as! cmyControlDoc).title
                            }
                            (bt as! cmyControlDoc).title = text
                            //text = ""
                        }
                        else {
                            bt.isHidden = true
                        }
                    } else {
                        bt.isHidden = bt is cmyControlDoc
                        text = ""
                    }
                }
            }
            for view in cell.subviews {
                if view is cmyCombo && !(view as! cmyCombo).isHidden {
                    (view as! cmyCombo).stringValue = text
                } else if view is cmyTextfield {
                    (view as! cmyTextfield).stringValue = text
                } else {
                    cell.textField?.stringValue = text
                }
            }
            //cell.toolTip = "Tooltip sur la cellule"
            //cell.addToolTip(<#T##rect: NSRect##NSRect#>, owner: <#T##Any#>, userData: <#T##UnsafeMutableRawPointer?#>)
            return cell
        }
        return nil
    }
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        if tableColumn is cmyColumn && (tableColumn as! cmyColumn).isSortable && tableView is cmyTable {
            for descriptor in tableView.sortDescriptors {
                if descriptor.key == tableColumn.identifier.rawValue {
                    if tableView is cmyTable {
                        (tableView as! cmyTable).triCourant = tableColumn.identifier.rawValue
                        (tableView as! cmyTable).ascending = descriptor.ascending
                    }
Swift.print("tableview didClick \(tableColumn.description)")
                    if (tableView as! cmyTable).parent.datasource.sort(cle: descriptor.key!, asc: descriptor.ascending) {
                        tableView.reloadData()
                    }
                    break;
                }
            }
        }
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
            tableCourante = getControl(tableView.identifier!.rawValue)
        }
        let aRow =  tableView.rowView (atRow: row, makeIfNecessary: false)
        return aRow == nil ? nil : aRow
    }
    
    public func tableViewSelectionIsChanging(_ notification: Notification) {
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView is cmyTable {
            let columnCtrl = (tableView as! cmyTable).getCellControl (ixColumn: tableView.clickedColumn, ixRow: row)
            if columnCtrl is cmyControlDoc {
                (columnCtrl as! cmyControlDoc).mouseDown()
                return false
            } else if (tableView as! cmyTable).state != .nonedition && columnCtrl is cmyTextfield {
                if (columnCtrl as! cmyTextfield).isEnabled {
                    columnCtrl?.becomeFirstResponder()
                    return false
                }
            }
            (tableView as! cmyTable).rowselected = row
        }
        return true
    }
    
    public func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
         Swift.print("sortDescriptorDidChange sur \(oldDescriptors.description)")
    }
}

// MARK: NSWindowDelegate
extension cbaseController: NSWindowDelegate {
    public func windowDidResize(_ notification: Notification) {
        if !internalSetFrame {
            window?.saveFrame(usingName: windowFrameAutosaveName)
        }
    }
    
    public func windowDidMove(_ notification: Notification) {
        window?.saveFrame(usingName: windowFrameAutosaveName)
    }
    
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        closeWindow()
        return true
    }
}
