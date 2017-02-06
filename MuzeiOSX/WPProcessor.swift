//
//  WPProcessor.swift
//  MuzeiOSX
//
//  Created by Naman on 18/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation
import Cocoa
import Kingfisher

class WPProcessor {
    
    let CURRENT_WP_TITLE = "current_wallpaper_title"
    let CURRENT_WP_URL = "current_wallpaper_url"
    let CURRENT_WP_PROCESSED_URL = "current_wallpaper_processed_url"
    
    func getWallpaperFileUrl(fileName: NSString, processed: Bool, random: Int) -> URL? {
        
        var url: URL?
        
        let nsApplicationDirectory = FileManager.SearchPathDirectory.applicationSupportDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(nsApplicationDirectory, nsUserDomainMask, true)
            .first as NSString?
        
        var dataPath = path?.appendingPathComponent("Muzei")
        
        if(processed) {
            dataPath = path?.appendingPathComponent("Muzei/processed")
        }
        
        if let dirPath = dataPath {
            var isDir : ObjCBool = true
            
            if !FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
                do {
                    try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                } catch  {
                    
                }
                
            }
            
            let fullURL = NSURL.fileURL(withPathComponents: [dirPath, fileName.deletingPathExtension.appending(String(random)).appending(".").appending(fileName.pathExtension)])
                
          url = fullURL

        }
        
        return url
    }
    
    func imageToFile(image: NSImage, imageURL: URL, ext: String) -> Bool {
        if ext == "png" {
            do {
                try image.savePNG(path: imageURL)
                return true
            } catch{
                
            }
        } else if ext == "jpeg" || ext == "jpg" {
            do {
                try image.saveJPEG(path: imageURL)
                return true
            } catch{
                
            }
        }
        return false
    }
    
    func processImage(originalImage: Image) ->Image {
        var processedImage: Image
        
        let processor = BlurImageProcessor(blurRadius: 20)
        processedImage = processor.process(item: ImageProcessItem.image(originalImage),
                                               options:[])!
        
        return processedImage
    }
    
    func saveCurrentWallpaper() -> Bool {
        
        
        let nsPicturesDirectory = FileManager.SearchPathDirectory.picturesDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsPicturesDirectory, nsUserDomainMask, true).first as NSString?
        
        let dataPath = paths?.appendingPathComponent("Muzei")

        if let dirPath = dataPath {
            
            var isDir : ObjCBool = true
            
            if !FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir) {
                do {
                    try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: false, attributes: nil)
                } catch  {
                    
                }
                
            }
            
            let prefs = UserDefaults.standard
            
            if let url = prefs.url(forKey: CURRENT_WP_URL) {
            
            let name: String = url.lastPathComponent
            let ext: String = url.pathExtension
            
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name as String)
            
            let image: NSImage
            
            do {
                try image = NSImage.init(data: Data.init(contentsOf: url, options: []))!
                
                return imageToFile(image: image, imageURL: imageURL, ext: ext)
            }
            catch {
                print("Error reading data")
            }
            }
            
        }
        
        return false
    }
    
    func saveWallpaperDetails(current: Wallpaper) {
        let prefs = UserDefaults.standard
        prefs.set(current.title, forKey: CURRENT_WP_TITLE)
        prefs.set(current.imageUrl, forKey: CURRENT_WP_URL)
        prefs.set(current.processedImageUrl, forKey: CURRENT_WP_PROCESSED_URL)
        prefs.synchronize()
    }
    
    func deletePreviousWallpaper(current : Wallpaper) {
        
        let nsApplicationDirectory = FileManager.SearchPathDirectory.applicationSupportDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(nsApplicationDirectory, nsUserDomainMask, true)
            .first as NSString?
        
        let dataPath = path?.appendingPathComponent("Muzei")
        
        let fileManager = FileManager.default
        var enumerator = fileManager.enumerator(atPath: dataPath!)
        
        while let file = enumerator?.nextObject() as? String {
            if !(file == current.imageUrl.lastPathComponent || file.contains("processed")) {
                do {
                    let fullURL = NSURL.fileURL(withPathComponents: [dataPath!, file])
                    try fileManager.removeItem(at: fullURL!)
                } catch {
                    print(error)
                }
            }
        }
        
        let processedPath = path?.appendingPathComponent("Muzei/processed")
        enumerator = fileManager.enumerator(atPath: processedPath!)
        
        while let file = enumerator?.nextObject() as? String {
            if !(file == current.processedImageUrl.lastPathComponent) {
                do {
                    let fullURL = NSURL.fileURL(withPathComponents: [processedPath!, file])
                    try fileManager.removeItem(at: fullURL!)
                } catch {
                    print(error)
                }
            }
        }
        
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

extension NSURL {
    
    func absoluteStringByTrimmingQuery() -> NSString? {
        if let urlcomponents = NSURLComponents(url: self as URL, resolvingAgainstBaseURL: false) {
            urlcomponents.query = nil
            return NSString(string: urlcomponents.string!)
        }
        return nil
    }
}
