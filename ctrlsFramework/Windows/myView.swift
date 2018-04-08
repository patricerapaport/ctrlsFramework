//
//  myView.swift
//  testinput
//
//  Created by Patrice Rapaport on 16/01/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Cocoa


open class cmyView: NSView {
    var clickingZones: [NSTableCellView]!
    
    func addClickingZone (aCell: NSTableCellView) {
        if clickingZones == nil {
            clickingZones = []
        }
        clickingZones.append(aCell)
    }
    
    override open func acceptsFirstMouse(for event: NSEvent?) -> Bool {
            return true;
    }
    
    override open func mouseDown(with event: NSEvent) {
        Swift.print("mouseLocation: \(event.description)")
    }
}
