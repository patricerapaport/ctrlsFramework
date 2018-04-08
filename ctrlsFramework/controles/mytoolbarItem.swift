//
//  cmyToolbarItem.swift
//  testinput
//
//  Created by Patrice Rapaport on 18/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

// Dans le cas d'une grille avec tabView, les boutons ne correspondent pas forcément aux assignations de base des méthodes de la fenêtre (ajouter, annuler, modifier, etc...)
// Dans ce cas, la fenetre doit surcharger la fonction setConfigs pour assigner par tabviewitem chaque bouton (voir grille locataire)
// La fenêtre doit également assigneé à la table attachée à la tabviewitem les sélecteurs enregistrer et annuler
// Lorsque la fonction tableViewSelectionDidChange du protocol NSTableViewDelegate est appelée, les boutons de la toolbar sont mis à jour (fontion setEtat) en fonction du nombre de rangées sélectionnées dans la table
// Lorsque la fonction didSelect du protocol NSTabViewDelegate est appelée, la toolbar est mise à jour
// Le controller peut contenir une méthode pour valider ou invalider le bouton. (voir paramàtres d'initialisation)

import Cocoa

class toolbarConfig {
    var nomConfig: String!
    var table: cmyTable!
    var typebouton: cmyTypesBoutons!
    var isVisible: Bool!
    var defaultAction: String!
    var etatRequis: Int = -1
    var nbSelectedRows: Int = -1
    var methodState: String!
    
    init (config: String, type: cmyTypesBoutons, visible: Bool, action: String?, etat: Int, selected: Int) {
        nomConfig = config
        typebouton = type
        isVisible = visible
        if action != nil {
            defaultAction = action
        }
        etatRequis = etat
        nbSelectedRows = selected
    }
    
    init (table: cmyTable, type: cmyTypesBoutons, visible: Bool, action: String?, etat: Int, selected: Int) {
        self.table = table
        typebouton = type
        isVisible = visible
        if action != nil {
            defaultAction = action
        }
        etatRequis = etat
        nbSelectedRows = selected
    }
    
    init (table: cmyTable, type: cmyTypesBoutons, visible: Bool, action: String?, etat: Int, methodState: String) {
        self.table = table
        typebouton = type
        isVisible = visible
        if action != nil {
            defaultAction = action
        }
        etatRequis = etat
        self.methodState = methodState
    }
}

class toolbarConfigs {
    var configs: [toolbarConfig]!
    init() {
        configs = []
    }
    
    deinit {
        configs.removeAll()
    }
}

open class cmyToolbarItem: NSToolbarItem {
    var typeBouton: cmyTypesBoutons = .autre
    var tbConfigs: toolbarConfigs!
    var isVisible: Bool = true
    var table: cmyTable!
    @IBInspectable var defaultAction: String!
    @IBInspectable var etatRequis: Int = -1 // -1 inconnu, 0 ... visible quand .nonedition, 1... visible quand edition
    @IBInspectable var nbSelectedRows: Int = -1 // -1 inconnu, 0 ... enabled tout le temps, 1 ... enabled si une seul rangée sélectionnée, 2 ... enabled quand plusieurs rangées sélectionnées
    @IBInspectable var methodState: String! // permet d'attribuer un nom de méthode du controller pour sélectionner ou non le bouton
    
    func _init() {
        switch label{
            case "Modifier" :
                typeBouton = .modifier
                if etatRequis == -1 {
                    etatRequis = 0
                }
                if nbSelectedRows == -1 {
                    nbSelectedRows = 1
                }
                if defaultAction == nil {
                    defaultAction = "Modifier"
                }
            case "Ajouter":
                typeBouton = .ajouter
                if etatRequis == -1 {
                    etatRequis = 0
                }
                if nbSelectedRows == -1 {
                    nbSelectedRows = 0
                }
                if defaultAction == nil {
                    defaultAction = "Ajouter"
                }
            case "Supprimer":
                typeBouton = .supprimer
                if etatRequis == -1 {
                    etatRequis = 0
                }
                if nbSelectedRows == -1 {
                    nbSelectedRows = 2
                }
                if defaultAction == nil {
                    defaultAction = "Supprimer"
                }
            case "Annuler":
                typeBouton = .annuler
                if etatRequis == -1 {
                    etatRequis = 1
                }
                if defaultAction == nil {
                    defaultAction = "Annuler"
                }
            case "Enregistrer":
                typeBouton = .enregistrer
                if etatRequis == -1 {
                    etatRequis = 1
                }
                if defaultAction == nil {
                    defaultAction = "Save"
                }
            case "Imprimer":
                typeBouton = .imprimer
            case "Reglement":
                typeBouton = .reglement
            default:
                typeBouton = .autre
        }
    }
    
    func addConfig(config: String, type: cmyTypesBoutons, visible: Bool, action: String?, etat: Int, selected: Int) {
        if tbConfigs == nil {
            tbConfigs = toolbarConfigs()
        }
        tbConfigs.configs.append(toolbarConfig(config: config, type: type, visible: visible, action: action, etat: etat, selected: selected))
    }
    
    func addConfig (table: cmyTable, type: cmyTypesBoutons, visible: Bool, action: String?, etat: Int, selected: Int) {
        if tbConfigs == nil {
            tbConfigs = toolbarConfigs()
        }
        tbConfigs.configs.append(toolbarConfig(table: table, type: type, visible: visible, action: action, etat: etat, selected: selected))
    }
    
    func addConfig (table: cmyTable, type: cmyTypesBoutons, visible: Bool, action: String?, etat: Int, methodState: String) {
        if tbConfigs == nil {
            tbConfigs = toolbarConfigs()
        }
        tbConfigs.configs.append(toolbarConfig(table: table, type: type, visible: visible, action: action, etat: etat, methodState: methodState))
    }
    
    func addConfig(config: String, type: cmyTypesBoutons) {
        addConfig(config: config, type: type, visible: false, action: nil, etat: -1, selected: -1)
    }
    
    func addConfig(table: cmyTable, type: cmyTypesBoutons) {
        addConfig(table: table, type: type, visible: false, action: nil, etat: -1, selected: -1)
    }
    
    func setConfig (nom: String) {
        if tbConfigs != nil && tbConfigs.configs != nil && tbConfigs.configs.count > 0 {
            for i in 0...tbConfigs.configs.count-1 {
                if tbConfigs.configs[i].nomConfig == nom {
                    let myConfig = tbConfigs.configs[i]
                    typeBouton      = myConfig.typebouton
                    etatRequis      = myConfig.etatRequis
                    nbSelectedRows  = myConfig.nbSelectedRows
                    defaultAction   = myConfig.defaultAction
                    isVisible       = myConfig.isVisible
                    methodState     = myConfig.methodState
                    table           = myConfig.table
                    break
                }
            }
        }
    }
    
    func setConfig (table: cmyTable) {
        if tbConfigs != nil && tbConfigs.configs != nil && tbConfigs.configs.count > 0 {
            for i in 0...tbConfigs.configs.count-1 {
                if tbConfigs.configs[i].table == table && tbConfigs.configs[i].typebouton == typeBouton {
                    let myConfig = tbConfigs.configs[i]
                    typeBouton      = myConfig.typebouton
                    etatRequis      = myConfig.etatRequis
                    nbSelectedRows  = myConfig.nbSelectedRows
                    defaultAction   = myConfig.defaultAction
                    isVisible       = myConfig.isVisible
                    methodState     = myConfig.methodState
                    self.table      = table
                    break
                }
            }
        }
    }
    
    func setAction() {
        
    }
    
    func setEtat(numberOfSelectedRows: Int) {
        if table != nil && methodState != nil {
            let controller = table.parent.controller
            let method = Selector(methodState+":")
            if controller.responds(to: method) {
                let res = controller.perform(method, with: self)
                if res == nil {
                    action = nil
                } else {
                    let bRes = Unmanaged<AnyObject>.fromOpaque(
                        res!.toOpaque()).takeUnretainedValue()
                    if (bRes as! NSNumber).intValue == 1  {
                        let methode = Selector(defaultAction+":")
                        action = methode
                    } else {
                        action = nil
                    }
                }
            } else {
                action = nil
            }
        } else {
            switch nbSelectedRows {
                case 0:
                    let methode = Selector(defaultAction+":")
                    action = methode
                case 1:
                    if numberOfSelectedRows == 1 && defaultAction != nil {
                        let methode = Selector(defaultAction+":")
                        action = methode
                    } else {
                        action = nil
                    }
                case 2:
                    if numberOfSelectedRows > 0 {
                        let methode = Selector(defaultAction+":")
                        action = methode
                    } else {
                        action = nil
                    }
                default:
                    action = nil
            }
        }
    }
    
    func removeFromToolbar() {
        if tbConfigs != nil {
            for config in tbConfigs.configs {
                if config.table != nil {
                    let sel = nomSelectors(rawValue: typeBouton.rawValue)
                    if sel != nil {
                        config.table.removeSelector (aName: nomSelectors(rawValue: typeBouton.rawValue)!)
                    }
                }
            }
        }
    }
    
    func insertInToolbar (controller: NSResponder, etat: etatWindow, index: Int) -> Bool {
        var tableCourante: cmyControl!
        if !isVisible  {
            return false
        }
        if (etat == .nonedition && etatRequis != 0) || (etat != .nonedition && etatRequis == 0) {
            return false
        }
        if controller is cbaseController {
            tableCourante = (controller as! cbaseController).tableCourante
            (controller as! cbaseController).window?.toolbar?.insertItem(withItemIdentifier: self.itemIdentifier, at: index)
        } else if controller is cbaseView {
            tableCourante = (controller as! cbaseView).tableCourante
            (controller as! cbaseView).view.window?.toolbar?.insertItem(withItemIdentifier: self.itemIdentifier, at: index)
        }
        if defaultAction != nil {
            if (etatRequis == 0 && etat == .nonedition) || (etatRequis == 1 && etat != .nonedition) {
                
                let nbTableSelected = tableCourante == nil ? 0 :  (tableCourante.ctrl as! NSTableView).numberOfSelectedRows
                
                let valider = tableCourante == nil || tableCourante.etat != .nonedition ||
                                (nbSelectedRows == -1 || nbSelectedRows == 0 || (nbSelectedRows == 1 && nbTableSelected == 1) || (nbSelectedRows == 2 && nbTableSelected > 0))
                if valider {
                    let methode = Selector(defaultAction+":")
                    if controller.responds(to: methode) {
                        action = methode
                    } else {
                        action = nil
                    }
                } else {
                    action = nil
                }
            }
        } else {
            action = nil
        }
        return true
    }
    
    func insertInToolbar (table: cmyTable, etat: etatWindow, index: Int) -> Bool {
        setConfig(table: table)
        if !isVisible {
            return false
        }
        let controller = table.parent.controller as! cbaseController
        controller.window?.toolbar?.insertItem(withItemIdentifier: self.itemIdentifier, at: index)
        var valider: Bool!
        let nbTableSelected = table.numberOfSelectedRows
        if defaultAction != nil {
            let sel = nomSelectors(rawValue: typeBouton.rawValue)
            if sel != nil {
                var tbl = table
                tbl.addSelector(aTarget: controller, aName: sel!, aAction: Selector(defaultAction+":"))
            }
            if methodState != nil {
                let method = Selector(methodState+":")
                if controller.responds(to: method) {
                    let res = controller.perform(method, with: self)
                    if res == nil {
                        valider = false
                    } else {
                        let bRes = Unmanaged<AnyObject>.fromOpaque(
                            res!.toOpaque()).takeUnretainedValue()
                        valider = (bRes as! NSNumber).intValue == 1 
                    }
                } else {
                    valider = false
                }
            } else if etatRequis == 0 && etat == .nonedition {
                valider =  nbSelectedRows == -1 || (nbSelectedRows == 0 && nbTableSelected == 0) || (nbSelectedRows == 1 && nbTableSelected == 1) || (nbSelectedRows == 2 && nbTableSelected > 0)
            } else if etatRequis == 1 && etat != .nonedition {
                valider = true
            }
            if valider {
                let methode = Selector(defaultAction+":")
                if controller.responds(to: methode) {
                    action = methode
                } else {
                    action = nil
                }
            } else {
                action = nil
            }
        } else {
            action = nil
        }
        return true
    }
    
    func setState (controller: NSResponder, etat: etatWindow) {
        let nextIndex = toolbar?.items.count
        var ctrlWindow: cbaseController!
        var ctrlView: cbaseView!
        var tableCourante: cmyControl!
        if controller is cbaseController {
            ctrlWindow = controller as! cbaseController
            ctrlView = nil
            if ctrlWindow.tableCourante != nil {
                tableCourante = ctrlWindow.tableCourante
            }
        }
        else if controller is cbaseView {
            ctrlView = controller as! cbaseView
            ctrlWindow = nil
            if ctrlView.tableCourante != nil {
                tableCourante = ctrlView.tableCourante
            }
        }
        
        if etat == .nonedition {
            if etatRequis != -1 {
                if (etatRequis == 0 && etat == .nonedition) || (etatRequis == 1 && etat != .nonedition) {
                    _ = insertInToolbar(controller: controller, etat: etat, index: nextIndex!)
                }
                return
            }
            switch typeBouton {
            case .supprimer:
                if ctrlWindow != nil {
                    ctrlWindow.window?.toolbar?.insertItem(withItemIdentifier: self.itemIdentifier, at: nextIndex!)
                    if tableCourante != nil && (tableCourante.ctrl as! NSTableView).numberOfSelectedRows > 0 {
                        action=#selector(ctrlWindow.Supprimer(_:))
                    } else {
                        action=nil
                    }
                    target = ctrlWindow
                } else if ctrlView != nil {
                    ctrlView.view.window?.toolbar?.insertItem(withItemIdentifier: self.itemIdentifier, at: nextIndex!)
                    if tableCourante != nil && (tableCourante.ctrl as! NSTableView).numberOfSelectedRows > 0 {
                        action=#selector(ctrlView.Supprimer(_:))
                    } else {
                        action=nil
                    }
                    target = ctrlView
                } else {
                    break
                }
            default:
                break
            }
        }
        else {
            if etatRequis != 0 {
                if (etatRequis == 1 && etat != .nonedition)  {
                    _ = insertInToolbar(controller: controller, etat: etat, index: nextIndex!)
                }
            }
        }
    }
    
}
