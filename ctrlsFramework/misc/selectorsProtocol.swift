//
//  mySelectorsProtocol.swift
//  testinput
//
//  Created by Patrice Rapaport on 07/11/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

enum nomSelectors : Int {
    case modification = 0
    case ajout       = 1
    case suppression = 2
    case annulation  = 3
    case save        = 4
    case autre       = 5
}

open class cmySelector: NSObject {
    var nom: nomSelectors
    var action: Selector?
    var target: cbaseController
    init (aTarget: cbaseController, aName: nomSelectors, aAction: Selector?) {
        nom = aName
        action = aAction
        target = aTarget
    }
}

protocol mySelectorProtocol {
    var selectors: [cmySelector] {get set}
    
    func hasSelector (_ nom: nomSelectors)->Bool
    func performAction (_ nom: nomSelectors)
}

extension mySelectorProtocol {
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
    
    mutating func addSelector (aTarget: cbaseController, aName: nomSelectors, aAction: Selector?) {
        if self.selectors == nil {
            self.selectors = []
        }
        if !self.hasSelector(aName) {
            self.selectors.append(cmySelector(aTarget: aTarget, aName: aName, aAction: aAction))
        }
    }
    
    mutating func removeSelector (aName: nomSelectors) {
        if self.selectors != nil && self.selectors.count > 0 {
            for index in 0...self.selectors.count-1 {
                let sel = self.selectors[index]
                if sel.nom == aName {
                    self.selectors.remove(at: index)
                    break
                }
            }
        }
    }
    
}
