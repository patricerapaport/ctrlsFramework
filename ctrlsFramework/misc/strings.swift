//
//  strings.swift
//  ctrlsFramework
//
//  Created by Patrice Rapaport on 07/04/2018.
//  Copyright © 2018 Patrice Rapaport. All rights reserved.
//

import Foundation

extension String {
    func toFloat() -> Float {
        if self.count == 0 {
            return 0
        }
        else {
            return (self as NSString).floatValue
        }
    }
    
    func toInt() -> Int {
        if self.count == 0 {
            return 0
        }
        else {
            return Int((self as NSString).intValue)
        }
    }
    
    func substr(from: Int, to:Int!) -> String {
        var index = self.index(self.startIndex, offsetBy: from)
        var res = String(self[index...])
        if to != nil {
            let to1 = 1 + to - from
            if to1 > res.count {
                return res
            }
            index = res.index(self.startIndex, offsetBy: to1);
            res = String(res[..<index])
        }
        return res
    }
}
