

//
//
//  myWindow.swift
//  testinput
//
//  Created by Patrice Rapaport on 19/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class cmyWindow: NSWindow {
    var controller: cbaseController!
    
    func getCtrls (_ ctrl: cmyControl) -> clisteControles? {
        if ctrl.controller is cbaseController {
            return (ctrl.controller as! cbaseController).ctrls
        }
        else
        if ctrl.controller is cbaseView {
            return (ctrl.controller as! cbaseView).ctrls
        }
        return nil
    }
    
    override open func sendEvent(_ event: NSEvent) {
        switch (event.type) {
        case .mouseExited, .mouseMoved, .leftMouseDragged,  .leftMouseUp, .scrollWheel,  .cursorUpdate: break
        case .leftMouseDown:
            break
            Swift.print("\n\n")
            Swift.print("\(event.description)")
            Swift.print("mouseLocationOutsideOfEventStream: \(mouseLocationOutsideOfEventStream)")
            //Swift.print("mouseLocation: \(event.mouseLocation)")
            let tableCourante = controller.tableCourante
            if tableCourante != nil  && (tableCourante!.tabviewItem == nil || tableCourante?.tabviewItem == tableCourante?.tabviewItem.tabView?.selectedTabViewItem) {
                let point = tableCourante?.ctrl.convert(mouseLocationOutsideOfEventStream, to: tableCourante?.ctrl)
                let frame = tableCourante?.ctrl.frame
                if frame?.contains(point!) == true {
                    let tbl = controller.tableCourante.ctrl as! cmyTable
                    let column = tbl.column(at: mouseLocationOutsideOfEventStream)
                    let row = tbl.row(at: mouseLocationOutsideOfEventStream)
                    if column != -1 && tableCourante?.ctrl is cmyTable {
                        let columnCtrl = (tableCourante?.ctrl as! cmyTable).getCellControl (ixColumn: column, ixRow: row)
                        if columnCtrl is cmyControlDoc {
                            (columnCtrl as! cmyControlDoc).mouseDown(with: event)
                        }
                    }
                    Swift.print("column cliquée: \(column.description)")
                }
            }
        case .mouseEntered:
            break
        case .keyDown, .keyUp :
            var currentFocus = controller.currentFocus
            if currentFocus?.ctrl is cmyTextFieldDecimal {
                if event.keyCode == 65 { // On remplace la virgule par un point
                    let newEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: event.context, characters: ".", charactersIgnoringModifiers: event.charactersIgnoringModifiers!, isARepeat: event.isARepeat, keyCode: 43)
                    super.sendEvent(newEvent!)
                    return
                }
            }
            if event.keyCode ==  ckeyboardKeys.escape {
                if event.type == .keyDown {
                    return
                }
                if currentFocus != nil && currentFocus?.tableView != nil && (currentFocus?.tableView as! cmyTable).hasSelector(.annulation) {
                    (currentFocus?.tableView as! cmyTable).performAction(.annulation)
                }
                else
                if windowController is cbaseController {
                    (windowController as! cbaseController).Annuler(self)
                    return
                }
            }
            else
                if (event.keyCode == ckeyboardKeys.enter || event.keyCode == ckeyboardKeys.enterNum || event.keyCode == ckeyboardKeys.tab) {
                    if event.modifierFlags.contains( .control) {
                        currentFocus?.controlEnterRecu()
                        return
                    }
                    if event.type == .keyDown {
                        return
                    }
                    if currentFocus == nil {
                        super.sendEvent(event)
                        return  
                    }
                    if !event.modifierFlags.contains( .shift) {
                        if !(currentFocus?.verifControl())! {
                            return
                        }
                    }
                    
                    if controller.myPopover != nil &&  controller.myPopover.isShown {
                        controller.myPopover.close()
                    }
                    
                    // a ce stade si currentFocus a la méthode nextfocus on doit l'appeler car cette méthode peut modifier la valeur de onSubmit du currentFocus
                    if currentFocus != nil && currentFocus?.nextFocusControl != nil && !event.modifierFlags.contains(.shift) {
                        _ = currentFocus?.controller.perform(currentFocus?.nextFocusControl, with: currentFocus?.ctrl)
                    }
                    if currentFocus != nil && (currentFocus?.onSubmit)! && !event.modifierFlags.contains(.shift) {
                        if currentFocus != nil && (currentFocus?.hasSelector(.save))! {
                            currentFocus?.performAction(.save)
                        } else if currentFocus != nil && currentFocus?.tableView != nil && (currentFocus?.tableView as! cmyTable).hasSelector(.save) {
                            (currentFocus?.tableView as! cmyTable).performAction(.save)
                        } else if currentFocus != nil && currentFocus?.outlineView != nil && (currentFocus?.outlineView as! cOutline).hasSelector(.save) {
                            (currentFocus?.outlineView as! cOutline).performAction(.save)
                        }
                        
                        // Après un save, le currentFocus peut changer
                        currentFocus = controller.currentFocus
                    }
                    let next: cmyControl?
                    if (event.modifierFlags.contains( .shift)) {
                        if currentFocus?.tableView != nil {
                            let table = currentFocus?.tableView
                            if table is cmyTable {
                                let row = (table as! cmyTable).rowselected
                                let controles = (table as! cmyTable).sourceRow(row).ctrls
                                next = controles?.previousFocus(currentFocus!)
                            } else {
                                next = nil
                            }
                        } else {
                            next = getCtrls(currentFocus!)?.previousFocus(currentFocus!)
                        }
                        
                    } else {
                        if currentFocus?.tableView != nil {
                            let table = currentFocus?.tableView
                            if table is cmyTable {
                                let row = (table as! cmyTable).rowselected
                                let controles = (table as! cmyTable).sourceRow(row).ctrls
                                next = controles?.nextFocus(currentFocus!)
                            } else {
                                next = nil
                            }
                        } else {
                            next = getCtrls(currentFocus!)?.nextFocus(currentFocus!)
                        }
                    }
                    if next != nil {
                        next?.ctrl.becomeFirstResponder()
                    }
                    return
                }
                else {
                    if currentFocus == nil || (event.type == .keyUp  && !(currentFocus?.acceptKey(event: event))!) {
                        return
                    }
                    #if DEBUG
                        //Swift.print("\n\n")
                        //if event.modifierFlags.contains(.shift) {
                        //    Swift.print("Shift actif\n")
                        //}
                        //Swift.print("\(event.description)")
                    #endif
            }
        default:
            #if DEBUG
                //Swift.print("\n\n")
                //Swift.print("\(event.description)")
            #endif
        }
        super.sendEvent(event)
    }
    
}
