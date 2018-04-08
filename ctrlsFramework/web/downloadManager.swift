//
//  downloadManager.swift
//  ctrlsFramework
//
//  Created by Patrice Rapaport on 07/04/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Foundation
import Alamofire

open class cdownloadManager {
    func makeCorrectUrl (_ initString: String)-> String {
        var els = initString.components(separatedBy: "/")
        var finalString = ""
        for i in 0...els.count-1 {
            if i > 0 {
                finalString = finalString + "/"
            }
            finalString = finalString + els[i].addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)!
        }
        return finalString
    }
    
    func startDownload(directory: String, docname: String) {
        let server = "http://" + preferenceManager.wsAdresse + "/documents/"
        let newpath = server + makeCorrectUrl(directory) + "/" + makeCorrectUrl(docname)
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(docname)
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(URL(string: newpath)!, to: destination).responseData { response in
            if let destinationUrl = response.destinationURL {
                print("destinationUrl \(destinationUrl.absoluteURL)")
            }
        }
    }
}
