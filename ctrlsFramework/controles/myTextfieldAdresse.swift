//
//  myTextfieldAdresse.swift
//  ctrlsFramework
//
//  Created by Patrice Rapaport on 07/04/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Foundation

open class cmyTextfieldAdresse: cmyTextfield {
    var cpost: String!
    var BP: String!
    var Cedex: String!
    var ville: String!
    @IBInspectable var suffixe: String = "" // dans un indentifier adressecorr le suffixe sera corr
    
    override open var stringValue: String {
        get {
            let res = super.stringValue
            let els = res.components(separatedBy: "\n")
            if els.count < 2 {
                return res
            }
            let cpostville = els[els.count-1]
            let firstSpace = cpostville.index(of: " ")
            if firstSpace != nil {
                let intFirstSpace = cpostville.distance(from: cpostville.startIndex, to: firstSpace!)
                cpost = cpostville.substr(from: 0, to: intFirstSpace - 1)
                let intNextIndex = cpostville.distance(from: firstSpace!, to: cpostville.index(after: firstSpace!)) + intFirstSpace
                ville = cpostville.substr(from: intNextIndex, to: nil)
                var result = ""
                for index in 0...els.count-2 {
                    if index > 0 {
                        result = result + "\n"
                    }
                    result = result+els[index]
                }
                return result
            } else {
                return res
            }
        }
        set (S) {
            var res = S
            if (cpost != nil || ville != nil) {
                res = res + "\n"
                if cpost != nil {
                    res = res+cpost
                    if ville != nil {
                        res = res + " "
                    }
                    cpost = nil
                }
                if (ville != nil) {
                    res = res + ville
                    ville = nil
                }
            }
            super.stringValue = res
        }
    }
    
    func identifierVirtuel() -> String {
        var res = identifier?.rawValue
        if suffixe != "" {
            let i = res?.index((res?.startIndex)!, offsetBy:(res?.count)! - suffixe.count)
            let intI = res?.distance(from: (res?.startIndex)!, to: i!)
            res = res?.substr(from: 0, to: intI)
        }
        return res!
    }
    
    //renseigne la valeur avec la valeur correspondante du dictionnaire
    func input (_ donnees: [String: String]) {
        let identifier = self.identifier!
        if donnees.keys.contains(identifier.rawValue) {
            let nomcpost: String = "cpost" + (!suffixe.isEmpty ? suffixe : "")
            let nomville: String = "ville" + (!suffixe.isEmpty ? suffixe : "")
            self.cpost = donnees[nomcpost]
            self.ville = donnees[nomville]
            self.stringValue = donnees[identifier.rawValue]!
        }
    }
}
