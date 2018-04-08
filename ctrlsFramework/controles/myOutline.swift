//
//  myNewOutline.swift
//  testinput
//
//  Created by Patrice Rapaport on 04/11/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

open class cOutline: NSOutlineView {
    var selectors: [cmySelector] = []
    var datasource: crowsTable!
    
    func hasSelector (_ nom: nomSelectors)->Bool {
        for sel in selectors {
            if (sel.nom == nom) {
                return true
            }
        }
        return false
    }
    
    func performAction (_ nom: nomSelectors) {
        for sel in selectors {
            if (sel.nom == nom) {
                sel.target.perform(sel.action, with: self)
                break
            }
        }
    }
}
