 //
//  peferenceManager.swift
//  testinput
//
//  Created by Patrice Rapaport on 26/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

private let webServerType = "webServerType"
private let webAdresseLocal = "webAdresseLocal"
private let webRepertoireLocal = "webRepertoireLocal"
private let webServiceLocal = "webServiceLocal"
private let webAdresseDistant = "webAdresseDistant"
private let webRepertoireDistant = "webRepertoireDistant"
private let webServiceDistant = "webServiceDistant"
private let longueurcomptes = "lencomptes"
private let wdFramesName = "windows"
private let pListKey = "plist"
 
enum serverType: Int {
    case local = 0
    case distant = 1
    case inconnu = 2
 }
 
open class PreferenceManager {
    private let userDefaults = UserDefaults.standard
    var adrlocal: String!
    var dirlocal: String!
    var svcelocal: String!
    var adrdistant: String!
    var dirdistant: String!
    var svcedistant: String!
    var lencomptes: Int!
    
    var wsServerType: serverType {
        get {
            let i = userDefaults.object(forKey: webServerType) as? Int
            if i == nil {
                return serverType(rawValue: serverType.inconnu.rawValue)!
            }
            return serverType(rawValue: i!)!
        }
        set (newType) {
            userDefaults.set(newType.rawValue, forKey: webServerType)
        }
    }
    
    var wsAdrLocal: String {
        get {
            let S = userDefaults.object(forKey: webAdresseLocal) as? String
            if S == nil {
                return ""
            } else {
                return S!
            }
        }
        set (adr) {
            userDefaults.set(adr, forKey: webAdresseLocal)
        }
    }
        
    var wsDirLocal: String {
        get {
            let S = userDefaults.object(forKey: webRepertoireLocal) as? String
            if S == nil {
                return ""
            } else {
                return S!
            }
        }
        set (rep) {
            userDefaults.set(rep, forKey: webRepertoireLocal)
        }
    }
    
    var wsSvceLocal: String {
        get {
            let S = userDefaults.object(forKey: webServiceLocal) as? String
            if S == nil {
                return ""
            } else {
                return S!
            }
        }
        set (svce) {
            userDefaults.set(svce, forKey: webServiceLocal)
        }
    }
    
    var wsAdrDistant: String {
        get {
            let S = userDefaults.object(forKey: webAdresseDistant) as? String
            if S == nil {
                return ""
            } else {
                return S!
            }
        }
        set (adr) {
            userDefaults.set(adr, forKey: webAdresseDistant)
        }
    }
    
    var wsDirDistant: String {
        get {
            let S = userDefaults.object(forKey: webRepertoireDistant) as? String
            if S == nil {
                return ""
            } else {
                return S!
            }
        }
        set (rep) {
            userDefaults.set(rep, forKey: webRepertoireDistant)
        }
    }
    
    var wsSvceDistant: String {
        get {
            let S = userDefaults.object(forKey: webServiceDistant) as? String
            if S == nil {
                return ""
            } else {
                return S!
            }
        }
        set (svce) {
            userDefaults.set(svce, forKey: webServiceDistant)
        }
    }
    
    var wsAdresse: String {
        get {
            return wsServerType == .local ? wsAdrLocal : wsAdrDistant
        }
    }
    
    var wsRepertoire: String {
        get {
            return wsServerType == .local ? wsDirLocal : wsDirDistant
        }
    }
    
    var wsService: String {
        get {
            return wsServerType == .local ? wsSvceLocal : wsSvceDistant
        }
    }
    
    var wdFrames: [String: NSRect]? {
        get {
            return userDefaults.object(forKey: wdFramesName) as? [String : NSRect]
        }
        set (frames) {
            userDefaults.set(frames, forKey: wdFramesName)
        }
    }
    
    var wsLencomptes: Int {
        get {
            let S = userDefaults.object(forKey: longueurcomptes) as? Int
            if S == nil {
                return 6
            } else {
                return S!
            }
        }
        set (len) {
            userDefaults.set(len, forKey: longueurcomptes)
        }
    }
    
    init() {
        registerDefaultPreferences()
    }
    
    func registerDefaultPreferences() {
        //let defaults = [webServiceHost: "127.0.0.1/compta1", webServiceServer: "svces1", webServiceName : "server.php"]
        //let defaults = [webServiceHost: "comptabilite.rapaport.fr", webServiceServer: "svces1", webServiceName : "server.php"]
        //userDefaults.register(defaults: defaults)
    }
    
    func reset() {
        userDefaults.removeObject(forKey: webServerType)
        userDefaults.removeObject(forKey: webAdresseLocal)
        userDefaults.removeObject(forKey: webRepertoireLocal)
        userDefaults.removeObject(forKey: webServiceLocal)
        userDefaults.removeObject(forKey: webAdresseDistant)
        userDefaults.removeObject(forKey: webRepertoireDistant)
        userDefaults.removeObject(forKey: webServiceDistant)
        userDefaults.removeObject(forKey: longueurcomptes)
    }
}
