//
//  documentPopoverController.swift
//  testinput
//
//  Created by Patrice Rapaport on 05/01/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Cocoa

class documentReference {
    var nomsociete: String!
    var repertoire: String!
    var document: String!
    
    init (nomsociete: String, repertoire: String, document: String) {
        self.nomsociete = nomsociete
        self.repertoire = repertoire
        self.document   = document
    }
    
    func actualDirectory() ->String {
        var res = nomsociete
        if repertoire != "" {
            res = res! + "/" + repertoire
        }
        return res!
    }
}

class documentPopoverController: NSViewController {
    var rows: crowsTable!
    var documents: [documentReference]!
    var downloadMgr: cdownloadManager!

    @IBOutlet weak var tableDocuments: NSTableView!
    
    init(rows: crowsTable) {
        self.rows = rows
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableDocuments.delegate = self
        tableDocuments.dataSource = self
    }
    
    func showDocument(row: Int) {
        downloadMgr = cdownloadManager()
        downloadMgr.startDownload(directory: documents[row].actualDirectory(), docname: documents[row].document)
    }

}

// MARK: NSTableViewDataSource
extension documentPopoverController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (rows != nil) {
            return rows!.count()
        } else {
            return 0
        }
    }
}

// MARK: NSTableViewDelegate
extension documentPopoverController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = rows?.item(row: row) else {
            return nil
        }
        
        var index = 0
        var textColor: NSColor?
        while (index <= tableView.tableColumns.count) {
            if (tableColumn == tableView.tableColumns[index]) {
                text = item.valeur(identifier: (tableColumn?.identifier)!.rawValue, interpreted: true) as! String
                textColor = item.textColor(identifier: (tableColumn?.identifier)!.rawValue)
                cellIdentifier = (tableColumn?.identifier)!.rawValue
                break
            }
            index += 1
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            if textColor != nil {
                cell.textField?.textColor = textColor
            }
            if cellIdentifier == "document" {
                for bt in cell.subviews {
                    if item.donnees.keys.contains(cellIdentifier) {
                        if documents == nil {
                            documents = []
                        }
                        if item.donnees.keys.contains("document") &&
                            item.donnees.keys.contains("nomsociete") &&
                            item.donnees.keys.contains("repertoire") {
                            documents.append(documentReference(nomsociete: item.donnees["nomsociete"]!, repertoire: item.donnees["repertoire"]!, document: item.donnees["document"]!))
                        }
                        if bt is cmyControlDoc {
                            bt.isHidden = false
                            let bouton = bt as! cmyControlDoc
                            if item.donnees.keys.contains("nomsociete") {
                                if item.donnees.keys.contains("repertoire") {
                                    bouton.directory = item.donnees["nomsociete"]! + "/" + item.donnees["repertoire"]!
                                } else {
                                    bouton.directory = item.donnees["nomsociete"]!
                                }
                            }
                            if item.donnees.keys.contains("document") {
                                bouton.document = item.donnees["document"]!
                            }
                            var rect = tableView.rect(ofRow: row)
                            rect = tableView.convert(rect, to: view)
                            var aFrame = tableView.convert(cell.frame, to: view)
                            aFrame.origin.y = rect.origin.y
                            (view as! cmyView).addClickingZone(aCell: cell)
                            //let trackingArea = NSTrackingArea(rect: aFrame, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self, userInfo: ["id": item.donnees["id"]!, "idtypedocument": item.donnees["idtypedocument"]!])
                            //view.addTrackingArea(trackingArea)
                            (bt as! cmyControlDoc).title = item.valeur(identifier: "document") as! String
                        } else {
                            (bt as! NSButton).title = "Document"
                        }
                    }
                    
                }
            }
            cell.textField?.stringValue = text
            
            //cell.toolTip = "Tooltip sur la cellule"
            //cell.addToolTip(<#T##rect: NSRect##NSRect#>, owner: <#T##Any#>, userData: <#T##UnsafeMutableRawPointer?#>)
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        Swift.print("didclick")
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        showDocument(row: row)
        return false
    }
}

// MARK gestion documents
extension documentPopoverController {
    
}
