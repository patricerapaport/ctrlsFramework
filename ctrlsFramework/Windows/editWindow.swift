//
//  myEditWindow.swift
//  testinput
//
//  Created by Patrice Rapaport on 18/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import Cocoa

open class ceditWindow: cbaseController {
    //surcharger la méthode quand on veut appliquer des modifications dans les données reçcues
    func transformDonnees () {
    }
    
    // surcharger la méthode quand on veut effectuer un traitement après la méthode input
    func afterInput() {
    }
}

extension ceditWindow: webServiceProtocolDelegate {
    @objc func afterSend(response: [String], reason: String, control: cmyControl?) {
    }
}
