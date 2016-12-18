//
//  WPProcessor.swift
//  MuzeiOSX
//
//  Created by Naman on 18/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation
import Cocoa

class WPProcessor {
    
    func getTempFileUrl() -> URL {
        let directory = NSTemporaryDirectory()
        let fileName = UUID().uuidString
        
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        
        return fullURL!
    }
    
    func saveWallpaper(image: NSImage, name: NSString) -> Bool {
        
        let nsPicturesDirectory = FileManager.SearchPathDirectory.picturesDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsPicturesDirectory, nsUserDomainMask, true)
        
        if let dirPath = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name as String)
            
            if name.pathExtension == "png" {
            do {
                try image.savePNG(path: imageURL)
                return true
            } catch{
                    
                }
            } else if name.pathExtension == "jpeg" {
                do {
                    try image.saveJPEG(path: imageURL)
                    return true
                } catch{
                    
                }
            }
            
        }
        return false
    }
}

extension NSImage {
    var imagePNGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .PNG, properties: [:])!
    }
    var imageJPEGRepresentation: Data {
        return NSBitmapImageRep(data: tiffRepresentation!)!.representation(using: .JPEG, properties: [:])!
    }
    
    func savePNG(path: URL) throws {
        try imagePNGRepresentation.write(to: path)
    }
    func saveJPEG(path: URL) throws {
        try imageJPEGRepresentation.write(to: path)
    }
}
