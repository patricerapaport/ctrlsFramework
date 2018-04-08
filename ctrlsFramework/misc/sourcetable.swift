//
//  csourceTableModel.swift
//  testinput
//
//  Created by Patrice Rapaport on 28/08/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

class crowsTable {
    var controller: NSResponder
    var rows: [csourceTable]!
    
    init (controller: NSResponder, response: [String]) {
        self.controller = controller
        if response.count < 3 {
            return
        }
        let nbzones = Int(response[2])
        var k=0
        var dict: [String: String] = [:]
        if rows != nil {
            rows.removeAll()
        }
        rows = []
        for index in 3...response.count-1 {
            let params = response[index].components(separatedBy: "=")
            if (params.count > 1) {
                if ["_first", "_prev", "_next", "_last"].contains(params[0]) {
                    continue
                }
                dict[params[0]] = params[1]
                k = k+1
                if k % nbzones! == 0 {
                    rows.append(csourceTable(controller: controller,  response: dict))
                    dict.removeAll()
                    k = 0
                }
            }
        }
        if dict.count > 0 {
            rows.append(csourceTable(controller: controller, response: dict))
        }

    }
    
    init (controller: NSResponder) {
        self.controller = controller
    }
    
    func count () -> Int {
        return rows == nil ? 0 : rows.count
    }
    
    func item (row: Int) -> csourceTable! {
        if rows != nil {
            return rows[row]
        }
        else {
            return nil
        }
    }
    
    func addRow (at: Int) {
        if rows == nil {
            rows = []
        }
        rows.insert(csourceTable(controller: controller, response:[:]), at: at)
    }
    
    func removeRow (at: Int) {
        rows.remove(at: at)
    }
    func sort (cle: String, asc: Bool) ->Bool {
        rows.sort(by: { (el1, el2) -> Bool in
            if asc {
                return el1.donnees[cle]! > el2.donnees[cle]!
            } else {
                return el1.donnees[cle]! < el2.donnees[cle]!
            }
        })
        return true
    }
}

class csourceTable {
    var myController: NSResponder!
    var donnees: [String: String]!
    var ctrls: clisteControles!
    
    init (controller: NSResponder, response: [String:String]) {
        myController = controller
        donnees = response
    }
    
    static func nbzones() ->Int {
        return 9
    }
    
    func getControl (_ identifier: String) -> cmyControl? {
        if ctrls != nil {
            return ctrls.getControl(identifier)
        } else {
            return nil
        }
        
    }
    
    func maj(donnees: [String: String]) {
        for (cle, _) in self.donnees {
            if donnees.keys.contains(cle) {
                self.donnees[cle] = donnees[cle]
            }
        }
    }
    
    func output() {
        if ctrls != nil && ctrls.controles.count > 0 {
            for control in ctrls.controles {
                var theIdentifier = control.identifier
                if control.ctrl is cmyCombo && (control.ctrl as! cmyCombo).txtassocie != nil {
                    theIdentifier = (control.ctrl as! cmyCombo).txtassocie.identifier!.rawValue
                    (control.ctrl as! cmyCombo).txtassocie.stringValue = control.stringValue
                }
                else if control.ctrl is cmyCustomCheckbox && (control.ctrl as! cmyCustomCheckbox).txtassocie != nil {
                    theIdentifier = (control.ctrl as! cmyCustomCheckbox).txtassocie.identifier!.rawValue
                    (control.ctrl as! cmyCustomCheckbox).txtassocie.stringValue = control.stringValue
                }
                if control.ctrl is cmyCombo {
                    // attention, faut-il mettre la clé ou le libellé dans le control associé?
                    donnees[control.identifier] = (control.ctrl as! cmyCombo).keyValue()
                    //donnees[theIdentifier] = (control.ctrl as! cmyCombo).getKey(selection: (control.ctrl as! cmyCombo).getIndex(valeur: control.stringValue))
                    donnees[theIdentifier] = control.stringValue
                    if (control.ctrl as! cmyCombo).txtassocie != nil {
                        (control.ctrl as! cmyCombo).txtassocie.stringValue = control.stringValue
                    }
                } else {
                    donnees[theIdentifier] = control.stringValue
                }
            }
        }
    }
    
    func valeur (identifier: String, interpreted: Bool!) -> Any {
        let nomMethode: String = "aff"+identifier.capitalized+"WithDonnees:"
        let methode = Selector(nomMethode)
        if myController.responds (to: methode) {
            //var res =  myController.perform(methode)
            let res = myController.perform(methode, with: donnees)
            let value = Unmanaged<AnyObject>.fromOpaque(
                res!.toOpaque()).takeUnretainedValue() as! String
            return value as Any
        } else {
            if (donnees.keys.contains(identifier)) {
                return donnees[identifier] as Any
            }
            else {
                Swift.print("csourceTable.swift, méthode valeur, la clé \(identifier) n'est pas dans le dictionnaire")
                return ""
            }
        }
    }
    
    func valeurInt (identifier: String, interpreted: Bool!) -> Int {
        let aValue = valeur(identifier: identifier, interpreted: interpreted)
        let result = aValue as? String
        return (result?.toInt())!
    }
    
    func valeur (identifier: String) -> Any {
        return valeur(identifier: identifier, interpreted: false)
    }
    
    func textColor (identifier: String) -> NSColor? {
        let nomMethode: String = "textColor"+identifier.capitalized+"WithDonnees:"
        let methode = Selector(nomMethode)
        if myController.responds (to: methode) {
            let res = myController.perform(methode, with: donnees)
            if res != nil {
                let value = Unmanaged<AnyObject>.fromOpaque(
                res!.toOpaque()).takeUnretainedValue() as! NSColor
                return value as NSColor?
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func toString (_ delimiteur: String = "|") ->String  {
        var res: String=""
        var first = true
        for (cle,valeur) in donnees {
            if !first {
                res = res + delimiteur
            } else {
                first = false
            }
            res = res + cle + "=" + valeur
        }
        return res
    }
}

struct mesDonnees<Key : Hashable, Value>: Collection {
    
    public typealias DictionaryType = Dictionary<Key, Value>
    private var dictionary: DictionaryType
    
    //Collection: these are the access methods
    public typealias IndexDistance = DictionaryType.IndexDistance
    public typealias Indices = DictionaryType.Indices
    public typealias Iterator = DictionaryType.Iterator
    public typealias SubSequence = DictionaryType.SubSequence
    
    public var startIndex: Index { return dictionary.startIndex }
    public var endIndex: DictionaryType.Index { return dictionary.endIndex }
    public subscript(position: Index) -> Iterator.Element { return dictionary[position] }
    public subscript(bounds: Range<Index>) -> SubSequence { return dictionary[bounds] }
    public var indices: Indices { return dictionary.indices }
    public subscript(key: Key)->Value? {
        get { return dictionary[key] }
        set { dictionary[key] = newValue }
    }
    public func index(after i: Index) -> Index {
        return dictionary.index(after: i)
    }
    
    //Sequence: iteration is implemented here
    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return dictionary.makeIterator()
    }
    
    //IndexableBase
    public typealias Index = DictionaryType.Index
}

