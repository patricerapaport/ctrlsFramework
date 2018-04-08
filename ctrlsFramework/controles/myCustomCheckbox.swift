/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An example demonstrating adding accessibility to an NSView subclass that behaves like a checkbox by implementing the NSAccessibilityCheckBox protocol.
*/

import Cocoa

/*
 IMPORTANT: This is not a template for developing a custom control.
 This sample is intended to demonstrate how to add accessibility to
 existing custom controls that are not implemented using the preferred methods.
 For information on how to create custom controls please visit http://developer.apple.com
*/

open class cmyCustomCheckbox: NSView {

    // MARK: - Internals
    var parent: cmyControl!
    var txtassocie: cmyTextfield! // utilisé dans une cellule de table
    var clickMethod: Selector!
    
    @IBInspectable var isFiltre: Bool = false
    @IBInspectable var onsubmit: Bool = false
    
    fileprivate struct LayoutInfo {
        static let CheckboxWidth = CGFloat(12.0)
        static let CheckboxHeight = CheckboxWidth
        static let CheckboxTextSpacing = CGFloat(4.0) // Spacing between box and text.
    }

    var checkboxText = NSLocalizedString("X", comment: "text of checkbox")
    
    var checked: Bool = false {
        didSet {
            if let actionHandler = actionHandler {
                actionHandler()
            }
        }
    }
    
    var controller: NSResponder {
        get {
            return parent.controller
        }
    }
    
    // MARK: - View Lifecycle
    
    required override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        //checked = false // So our actionHandler is called when first added to the window.
    }
    
    // MARK: - Events
 
    var actionHandler: (() -> Void)?

    // MARK: - Mouse Events
    
    fileprivate func toggleCheckedState () {
        checked = !checked
        //NSAccessibilityPostNotification(self, NSAccessibilityNotificationName.valueChanged)
        needsDisplay = true
        if clickMethod != nil {
            parent.controller.perform(clickMethod, with: self)
        }
    }
    
    override open func mouseUp(with event: NSEvent) {
        if parent.etat != .nonedition || isFiltre {
            toggleCheckedState()
        }
    }

    // MARK: - Key Event
    
    override open func keyDown(with event: NSEvent) {
        if parent.etat != .nonedition || isFiltre {
            if event.keyCode == 49 {
                // Space character was types.
                toggleCheckedState()
            } else {
                super.keyDown(with: event)
            }
        }
    }

    // MARK: - Drawing

    override open func draw(_ dirtyRect: NSRect) {
        // Draw the checkbox box.
        if (isHidden) {
            return
        }
        var boxImage: NSImage
        //let imageName = checked ? "checkboxSelected" : "checkboxUnselected"
        let imageName = "CustomCheckboxUnselected"
        //boxImage = NSImage(named: NSImage.Name(rawValue: imageName))!
        boxImage = NSImage(imageLiteralResourceName: imageName)
        let boxRect = NSRect(x: bounds.origin.x,
                             y: bounds.origin.y + 1,
                             width: LayoutInfo.CheckboxWidth,
                             height: LayoutInfo.CheckboxHeight)
        boxImage.draw(in: boxRect, from: NSRect.zero, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        // Draw the checkbox text.
        //let textAttributes = [
        //    NSAttributedStringKey.font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
        //    NSAttributedStringKey.foregroundColor: NSColor.black
        //]
        if checked {
            let textAttributes = [
                NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: NSFont.systemFontSize),
                NSAttributedStringKey.foregroundColor: NSColor.black
            ]
            let x = bounds.origin.x + 1
            var y = bounds.origin.y
            if parent != nil && parent.tableView == nil {
                y = y - 4
            } else {
                y = y - 5
            }
            let textRect = NSRect(x: x,
                                  y: y,
                                  width: bounds.size.width,
                                  height: bounds.size.height)
            checkboxText.draw(in: textRect, withAttributes: textAttributes)
        }
        
        // Draw the focus ring.
        //NSFocusRingPlacement.only.set()
        var window: NSWindow!
        if parent != nil {
            if parent.controller is cbaseController {
                window = (parent.controller as! cbaseController).window
            }
            else
                if parent.controller is cbaseView {
                    window = (parent.controller as! cbaseView).view.window
            }
        
            if window.firstResponder == self {
            // NSSetFocusRingStyle(NSFocusRingAbove);
            // or
                NSFocusRingPlacement.below.set();
                NSFocusRingPlacement.above.set()
                setKeyboardFocusRingNeedsDisplay(self.bounds)
                //let ovalPath = NSBezierPath(rect: boxRect)
                let Rect = CGRect(x: 0.0, y: 0.0, width: 14.0, height: 14.0)
                let ovalPath = NSBezierPath(rect: NSInsetRect(Rect, 0.0, 0.0))
                ovalPath.stroke()
            }
        }
    }
    
}

// MARK: -

extension cmyCustomCheckbox {
    
    // MARK: First Responder
    
    // Set to allow keyDown to be called.
    override open var acceptsFirstResponder: Bool { return true }
    
    override open func becomeFirstResponder() -> Bool {
        if parent == nil {
            needsDisplay = true
            return true
        }
        if (parent.tableView != nil && parent.tableView is cmyTable && (parent.tableView as! cmyTable).state == .nonedition) || (parent.tableView == nil && parent.controllerState == .nonedition) && !isFiltre {
            return false
        }
        
        var bRes = true
        if bRes {
            if parent != nil {
                if controller is cbaseController {
                    (controller as! cbaseController).currentFocus = parent
                }
                else
                if controller is cbaseView {
                    (controller as! cbaseView).currentFocus = parent
                }
            }
        }
        bRes = super.becomeFirstResponder()
        if controller is cbaseController {
            (parent.controller as! cbaseController).window?.makeFirstResponder(self)
        }
        else
        if controller is cbaseView {
            (parent.controller as! cbaseView).view.window?.makeFirstResponder(self)
        }
        needsDisplay = true
        return bRes
    }
    
    override open func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        needsDisplay = true
        return didResignFirstResponder
    }
    
    var stringValue: String {
        get {
            return checked ? "1" : "0"
        }
        set (S) {
            if S == "" || S == "0" {
                checked = false
            } else {
                checked = true
            }
            needsDisplay = true
        }
    }
    
    func input (_ aValue: String) {
        if aValue == "" {
            checked = false
        } else {
            checked = true
        }
    }
}

// MARK: -

extension cmyCustomCheckbox {
    
    // MARK: Accessibility
    
    override open func accessibilityValue() -> Any? {
        return checked
    }
    
    override open func accessibilityLabel() -> String? {
        return checkboxText
    }
    
    override open func accessibilityPerformPress() -> Bool {
        // User did control-option-space keyboard shortcut.
        toggleCheckedState()
        return true
    }
    
}

