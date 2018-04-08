//
//  mynewtabviewitem.swift
//  testinput
//
//  Created by Patrice Rapaport on 19/10/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class cmyTabviewItem: NSTabViewItem {
    var parent: cmyControl!
    var tbConfigs: toolbarConfigs!
    @IBInspectable var changeWhileEdition: Bool = false
    @IBInspectable var editionOnlyWhenSelected: Bool = true
    
    func shouldSelect() -> Bool {
        if (parent.controllerState == .edition || parent.controllerState == .ajout) && !changeWhileEdition {
            return false
        }
        let nomMethode: String =  "shouldSelect"+((identifier as? String)?.capitalized)!+"WithCtrl:"
        let methode = Selector(nomMethode)
        
        if parent.controller.responds (to: methode) {
            //controller.perform(methode)
            let res = parent.controller.perform(methode, with:self)
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
}
