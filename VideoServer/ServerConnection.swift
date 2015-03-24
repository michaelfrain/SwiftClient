//
//  ServerConnection.swift
//  VideoServer
//
//  Created by Michael Frain on 3/23/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit

class ServerConnection: HTTPConnection {
    // Note: We can't use this class yet, until Apple figures out the issues with introspection in Swift. Use ObjcServerConnection instead.
    override func supportsMethod(method: String!, atPath path: String!) -> Bool {
        if method == "POST" {
            NSLog("YES")
            return true
        }
        
        return super.supportsMethod(method, atPath: path)
    }
    
    override func expectsRequestBodyFromMethod(method: String!, atPath path: String!) -> Bool {
        if method == "POST" {
            NSLog("YES")
            return true
        }
        
        return super.supportsMethod(method, atPath: path)
    }
   
    override func httpResponseForMethod(method: String!, URI path: String!) -> NSObject! {
        let filePath = filePathForURI(path)
        
        if !filePath.hasPrefix(AddressHelper.documentsDirectory()) {
            return nil
        }
        
        let relativePath = filePath.substringFromIndex(advance(AddressHelper.documentsDirectory().startIndex, AddressHelper.documentsDirectory().utf16Count))
        
        if relativePath == "/upload" {
            
        } else if relativePath == "/download" {
            
        }
        
        return nil
    }
}
