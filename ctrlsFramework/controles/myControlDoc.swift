//
//  clControlDoc.swift
//  testinput
//
//  Created by Patrice Rapaport on 02/09/2017.
//  Copyright © 2017 Patrice Rapaport. All rights reserved.
//

import AppKit
import Foundation

var globalBookmarks = [URL: Data]()
var bookmarksLoaded: Bool = false

func bookmarkPath() -> String {
    // bookmarks saved in document directory
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    url = url.appendingPathComponent("Bookmarks.dict")
    return url.path
} 

func loadBookmarks() {
    let path = bookmarkPath()
    globalBookmarks = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [URL: Data] ?? [:]
    for bookmark in globalBookmarks {
        restoreBookmark(bookmark)
    }
}

func restoreBookmark(_ bookmark: (key: URL, value: Data)) {
    
    let restoredUrl: URL?
    var isStale = false     // parameter for URL.init
    
    do {
        restoredUrl = try URL.init(resolvingBookmarkData: bookmark.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
    }
    catch
    {
        Swift.print ("Error restoring bookmarks")
        restoredUrl = nil
    }
    
    if let url = restoredUrl {
        if isStale {
            // handle if needed
        } else  {
            if !url.startAccessingSecurityScopedResource() {
                Swift.print ("Couldn't access: \(url.path)")
            } else {
                // handle if needed
            }
        }
    }
}

func storeBookmark(url: URL) {
    do {
        let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        globalBookmarks[url] = data
    } catch {
        Swift.print ("Error storing bookmarks")
    }
}

func saveBookmarks() {
    let path = bookmarkPath()
    NSKeyedArchiver.archiveRootObject(globalBookmarks, toFile: path)
}



open class cmyControlDoc: NSButton {
    var document: String!
    var directory: String!
    var trackingArea: NSTrackingArea?
    var downloadMgr: cdownloadManager!
    
    override open var acceptsFirstResponder: Bool {return false}
  
    
    override open func mouseEntered(with event: NSEvent) {
        Swift.print("\(String(describing: self.identifier)) Mouse entered")
    }
    
    override open func mouseExited(with event: NSEvent) {
        Swift.print("\(String(describing: self.identifier)) Mouse exited")
    }
    
    func mouseDown() {
        downloadMgr = cdownloadManager()
        downloadMgr.startDownload(directory: directory, docname: document)
    }
    
    func mouse1Down() {
        if !bookmarksLoaded {
            loadBookmarks()
        }
        Swift.print("\(String(describing: self.identifier)) Mouse down")
        var repertoire = "/users/patricerapaport/Sites/compta1/Documents/"+directory+"/"+document
        Swift.print("\(repertoire)")
        //var dir: UnsafeMutablePointer<ObjCBool>!
        let manager = FileManager.default
        var appSupportDir: URL!
        //var appDirectory: URL!
        let possibleDirectories = manager.urls(for: .userDirectory, in: .localDomainMask) //.userDirectory
        if possibleDirectories.count >= 1 {
            appSupportDir = possibleDirectories[0]
            let bRes = manager.fileExists(atPath: appSupportDir.path)
            if bRes {
                Swift.print("\(appSupportDir.path) existe")
            } else {
                Swift.print("\(appSupportDir.path) n'existe pas")
            }
        }
        if appSupportDir != nil {
            Swift.print("directory: \(appSupportDir)")
            
            repertoire = appSupportDir.path + "/patricerapaport/Sites/compta1/documents/" + directory + "/" + document
            var bRes = manager.fileExists(atPath: repertoire)
            if bRes {
                Swift.print("\(repertoire) existe")
            } else {
                Swift.print("\(repertoire) n'existe pas")
            }
            
            bRes = manager.isReadableFile(atPath: repertoire)
            if bRes {
                Swift.print("\(repertoire) accessible")
            } else {
                Swift.print("\(repertoire) non accessible")
                //if true {
                    let openPanel = NSOpenPanel()
                    openPanel.message = "Authorize access to file"
                    openPanel.prompt = "Authorize"
                    openPanel.canChooseFiles = false
                    openPanel.canChooseDirectories = true
                    openPanel.canCreateDirectories = false
                    openPanel.begin() {
                        (result) -> Void in
                        let res =  result
                        Swift.print("res=\(res)")
                        if (res.rawValue == 1) {
                            storeBookmark(url: openPanel.url!)
                            saveBookmarks()
                        }
                    }
                //}
                //storeBookmark(url: URL(fileURLWithPath: repertoire))
                //saveBookmarks()
                
                bRes = manager.isReadableFile(atPath: repertoire)
                if bRes {
                    Swift.print("\(repertoire) accessible")
                } else {
                    Swift.print("\(repertoire) non accessible")
                }
                //if let data = NSMutableData(contentsOf: fileToReadURL) {
                    // Now you can proceed as with non sandboxed
                //}
            }
            let workSpace =  NSWorkspace.shared
            bRes = workSpace.openFile(repertoire)
        }
    }
}
