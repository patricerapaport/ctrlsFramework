//
//  myNewCheckbox.swift
//  testinput
//
//  Created by Patrice Rapaport on 18/10/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class cmyCheckbox: NSButton {
    var parent: cmyControl!
    
    var controller: NSResponder? {
        get {
            return parent != nil ? parent.controller : nil
        }
    }
    
    var myWindow: NSWindow? {
        get {
            if controller is cbaseController {
                return (controller as! cbaseController).window!
            }
            else
            if controller is cbaseView {
                return (controller as! cbaseView).view.window!
            }
            return nil
        }
    }
    
    var controllerState: etatWindow {
        get {
            if controller is cbaseController {
                return (controller as! cbaseController).state
            }
            else
            if controller is cbaseView {
                return (controller as! cbaseView).state
            }
            return .nonedition
        }
    }
    
    override open var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override open func becomeFirstResponder() -> Bool {
        if parent == nil {
            needsDisplay = true
            return true
        }
        if controllerState == .nonedition {
            return false
        }
        
        var bRes = true
        if bRes {
            if parent != nil {
                if controller is cbaseController {
                    (controller as! cbaseController).currentFocus = parent
                }
                else if controller is cbaseView {
                    (controller as! cbaseView).currentFocus = parent
                }
            }
        }
        bRes = super.becomeFirstResponder()
        myWindow?.makeFirstResponder(self)
        needsDisplay = true
        return bRes
    }
    
    override open func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        needsDisplay = true
        return didResignFirstResponder
    }
    
    override open var stringValue: String {
        get {
            return self.state.rawValue == 1 ? "1" : "0"
        }
        set (S) {
            if S == "" || S == "0" {
                self.state = NSControl.StateValue(rawValue: 0)
            } else {
                self.state = NSControl.StateValue(rawValue: 1)
            }
        }
    }
    
    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let nomMethode: String = "chgt"+(self.identifier?.rawValue.capitalized)!+"WithCtrl:"
        let methode = Selector(nomMethode)
        if (controller?.responds (to: methode))! {
            _ = controller?.perform(methode, with:self as NSControl)
        }
    }
    
    func isChecked()-> Bool {
        return stringValue != "0"
    }
    
    func input (_ aValue: String) {
        if aValue == "" {
            self.intValue = 0
        } else {
            self.intValue = Int32(aValue)!
        }
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw the focus ring.
        if myWindow?.firstResponder == self {
            // NSSetFocusRingStyle(NSFocusRingAbove);
            // or
            NSFocusRingPlacement.below.set();
            NSFocusRingPlacement.above.set()
            setKeyboardFocusRingNeedsDisplay(self.bounds)
            //let ovalPath = NSBezierPath(rect: boxRect)
            let ovalPath = NSBezierPath(rect: NSInsetRect(self.bounds, 0.0, 0.0))
            ovalPath.stroke()
        }
    }
}
