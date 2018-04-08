//
//  nums.swift
//  ctrlsFramework
//
//  Created by Patrice Rapaport on 07/04/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Foundation

extension Float {
    func toString() ->String {
        let myFormat: String = "%.2f"
        return String(format: myFormat, self)
    }
    
    func toString(decimales: Int) ->String {
        let myFormat: String = "%." + String(decimales) + "f"
        return String(format: myFormat, self)
    }
    
    func toMonetaire() -> String {
        var intValues: [Int] = []
        var reste = self
        while reste > 1000 {
            let aValue = Int(reste / 1000)
            intValues.append(aValue)
            reste = reste - Float(1000*aValue)
        }
        var szRes: String = ""
        for piece in intValues {
            if szRes != "" {
                szRes = szRes + " "
            }
            if szRes != "" && piece < 10 {
                szRes = szRes + "00"+piece.toString()
            } else if szRes != "" && piece < 100 {
                szRes = szRes + "0" + piece.toString()
            } else {
                szRes = szRes + piece.toString()
            }
        }
        if szRes != "" {
            szRes = szRes + " "
        }
        if intValues.count > 0 && reste < 10 {
            szRes = szRes + "00" + reste.toString()
        } else if intValues.count > 0 && reste < 100 {
            szRes = szRes + "0" + reste.toString()
        } else {
            szRes = szRes + reste.toString()
        }
        return szRes
    }
}

extension Int {
    func toString() -> String {
        return String(self)
    }
}
