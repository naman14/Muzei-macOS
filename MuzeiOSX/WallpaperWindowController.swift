//
//  WallpaperWindowController.swift
//  MuzeiOSX
//
//  Created by Naman on 07/02/17.
//  Copyright © 2017 naman14. All rights reserved.
//

import Foundation
import Cocoa

class WallpaperWindowController: NSWindowController {
    
    @IBOutlet weak var titleText: NSTextField!
    let CURRENT_WP_TITLE = "current_wallpaper_title"
    let CURRENT_WP_URL = "current_wallpaper_url"
    
    @IBOutlet weak var previewImage: NSImageView!
    
    override func windowDidLoad() {
        window?.title = "Preferences"
        
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground  = true
        window?.titleVisibility = NSWindowTitleVisibility.hidden;

        updateWindow()
    }
    
    
    func updateWindow() {
        
        NSApp.activate(ignoringOtherApps: true)
        
        let prefs = UserDefaults.standard
        
        if let url = prefs.url(forKey: CURRENT_WP_URL) {
                var image: NSImage
            
            titleText.stringValue = prefs.string(forKey: CURRENT_WP_TITLE)!
            do {
                try image = NSImage.init(data: Data.init(contentsOf: url, options: []))!
                previewImage.image = image
                
                previewImage.shadow = NSShadow()
                previewImage.layer?.shadowColor = NSColor.black.cgColor
                previewImage.layer?.shadowOpacity = 1
                previewImage.layer?.shadowOffset = CGSize.zero
                previewImage.layer?.shadowRadius = 5
            }
            catch {
                print("Error reading data")
            }
        }

        
    }
}
