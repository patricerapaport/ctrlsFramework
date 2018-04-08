//
//  myNexTextfieldNum.swift
//  testinput
//
//  Created by Patrice Rapaport on 15/11/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit

//MARK: opérations dans zone de saisie
struct extractionNumerique {
    var start: Int!
    var stop: Int!
    var strs: [String] = []
}

open class cmySaisieNumerique {
    var stringInitiale: String
    var stringFinale: String
    init (_ S: String) {
        stringInitiale = S
        stringFinale = S
    }
    
    func resultat() ->String {
        if stringInitiale == "" || stringInitiale.isEmpty {
            return stringInitiale
        }
        if verifParentheses(S: stringInitiale) {
            let valeur = _constructLex(S: stringInitiale)
            if valeur.count == 2 && valeur[0] == "-" { // cas d'une somme négative
                return stringInitiale
            } else {
                return analyze(valeur: valeur)[0]
            }
        }
        return stringFinale
    }
    
    func verifParentheses(S: String) -> Bool {
        var parOpen = 0
        var parClose = 0
        for character in S {
            if character == "(" {
                parOpen = parOpen + 1
            } else if character == ")" {
                parClose = parClose + 1
            }
        }
        if parOpen == parClose {
            return true
        } else {
            return false
        }
    }
    
    func _constructLex (S: String) ->[String] {
        var startIndex = 0
        let chaine = (S as NSString).components(separatedBy: .whitespaces).joined()
        var result: [String] = []
        var i = -1
        while (i < chaine.count-1)  {
            i = i + 1
            let str = chaine.substr(from: i, to: i)
            if str == "." || Int(str) != nil {
                continue
            }
            if i > startIndex {
                result.append(chaine.substr(from: startIndex, to: i-1))
                result.append(str)
                startIndex = i+1
            } else if i == startIndex {
                result.append(str)
                startIndex = startIndex + 1
            }
        }
        if startIndex < chaine.count {
            result.append(chaine.substr(from: startIndex, to: i))
        }
        return result
    }
    
    func extractParenthese (valeur: [String], start: Int) -> extractionNumerique {
        var result = extractionNumerique()
        result.start = start
        for index in start...valeur.count-1 {
            if valeur[index] != ")" {
                result.strs.append(valeur[index])
                result.stop = index
            } else {
                break
            }
        }
        return result
    }
    
    func analyze (valeur: [String]) -> [String] {
        var resArray = valeur
        //var index = 0
        for index in 0...resArray.count-1 { // ON cherche les parenthèses
            if resArray[index] == "(" {
                //chercher s'il uy a une nouvelle parenth!se ouverte avant la parenthèse de fin. Si oui il y a parenth§ses imbriquées à traiter avant
                var reste = resArray
                reste.removeSubrange(0..<index+1)
                let nextParenthese = reste.index(of: "(")
                if nextParenthese != nil {
                    let int1 = reste.startIndex.distance(to: nextParenthese!)
                    let nextParentheseStop = reste.index(of: ")")
                    let int2 = reste.startIndex.distance(to: nextParentheseStop!)
                    if int1 < int2 {
                        continue
                    }
                }
                let extract = extractParenthese(valeur: resArray, start: 1 + index)
                resArray.removeSubrange(index..<2+extract.stop)
                let aArray = analyze(valeur: extract.strs)
                resArray.insert(contentsOf: aArray, at: index)
                
                if resArray.count > 1 {
                    //resArray = analyze(valeur: extract.strs)
                    resArray = analyze(valeur: resArray)
                }
                break
            }
        }
        
        if resArray.count > 3 {
            for index in 0...resArray.count-1 { // On cherche les multiplicateurs
                if resArray[index] == "*" {
                    var extract = extractionNumerique()
                    extract.strs = [resArray[index-1], resArray[index], resArray[index+1]]
                    resArray.removeSubrange(index-1..<index+2)
                    
                    let resOpe = analyze(valeur: extract.strs)
                    if index < resArray.count {
                        resArray.insert(resOpe[0], at: index-1)
                    } else {
                        resArray.append(resOpe[0])
                    }
                    
                    if resArray.count > 1 {
                        resArray = analyze(valeur: resArray)
                    }
                    break
                }
            }
        }
        
        if resArray.count > 3 {
            for index in 0...resArray.count-1 { // On cherche les diviseurs
                if resArray[index] == "/" {
                    var extract = extractionNumerique()
                    extract.strs = [resArray[index-1], resArray[index], resArray[index+1]]
                    resArray.removeSubrange(index-1..<index+2)
                    
                    let resOpe = analyze(valeur: extract.strs)
                    if index < resArray.count {
                        resArray.insert(resOpe[0], at: index-1)
                    } else {
                        resArray.append(resOpe[0])
                    }
                    
                    if resArray.count > 1 {
                        resArray = analyze(valeur: resArray)
                    }
                    break
                }
            }
        }
        
        if resArray.count == 1 {
            return resArray
        }
        
        let left = Float(resArray[0])
        var resOperation: Float = 0.00
        if resArray[0] == "-" && resArray.count == 2 {
            resOperation = -Float(resArray[1])!
        } else {
            let right = Float(resArray[2])
            let operande = resArray[1]
            switch operande {
                case "*": resOperation = left! * right!
                case "/": resOperation = left! / right!
                case "+": resOperation = left! + right!
                case "-": resOperation = left! - right!
                default: break
            }
        }
        
        for _ in 0...resArray.count-1 {
            resArray.remove(at: 0)
        }
        resArray.insert(String(resOperation), at: 0)
        if resArray.count > 1 {
            resArray = analyze(valeur: resArray)
        }
        
        return resArray
    }
}


// MARK: myNextTextFieldNum
open class cmyTextFieldNum: cmyTextfield {
    var Token = ["+", "-", "*", "/", "(", ")"]
    
    func _constructLex () {
        var startIndex = 0
        let chaine = stringValue.components(separatedBy: .whitespaces).joined()
        var result: [String] = []
        var i = -1
        while (i < chaine.count-1)  {
            i = i + 1
            let str = chaine.substr(from: i, to: i)
            if str == "." || Int(str) != nil {
                continue
            }
            if i > startIndex {
                result.append(chaine.substr(from: startIndex, to: i-1))
                result.append(str)
                startIndex = i+1
            } else if i == startIndex {
                result.append(str)
                startIndex = startIndex + 1
            }
        }
        result.append(chaine.substr(from: startIndex, to: i))
    }
    
    override open func verifCoherence()->Bool {
        let bRes = super.verifCoherence()
        if bRes {
            let S = stringValue
            let finalS = cmySaisieNumerique (S).resultat()
            if finalS != S {
                stringValue = finalS
                return false
            }
        }
        return bRes
    }
}
