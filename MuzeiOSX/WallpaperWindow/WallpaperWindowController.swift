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
    
    let CURRENT_WP_TITLE = "current_wallpaper_title"
    let CURRENT_WP_URL = "current_wallpaper_url"
    let CURRENT_WP_BYLINE = "current_wallpaper_byline"
    let CURRENT_WP_ATTRIBUTION = "current_wallpaper_attribution"
    let CURRENT_WP_DETAILS_URL = "current_wallpaper_details_url"

    @IBOutlet weak var titleText: NSTextField!
    @IBOutlet weak var previewImage: NSImageView!
    @IBOutlet weak var bylineText: NSTextField!
    @IBOutlet weak var attributionText: NSTextField!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    @IBOutlet weak var linkButton: NSButton!
    
    var menuController: MenuController?

    @IBAction func configureClick(_ sender: NSButton) {
        if(menuController != nil) {
            menuController?.openPreferences()
        }
    }
    
    @IBAction func linkClick(_ sender: NSButton) {
        if let URL = URL(string: UserDefaults.standard.string(forKey: CURRENT_WP_DETAILS_URL)!) {
            if NSWorkspace.shared.open(URL) {
            }
        }
    }
    
    func setMenuController(controller: MenuController) {
        self.menuController = controller
    }
    
    override func windowDidLoad() {
        window?.title = "Wallpaper"
        
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground  = true
        window?.titleVisibility = NSWindow.TitleVisibility.hidden;
        loadingIndicator.isHidden = false
        loadingIndicator.isIndeterminate = true
        loadingIndicator.startAnimation(nil)
        updateWindow()
        
    }
    

    func updateWindow() {
        
        previewImage.image = nil
        previewImage.alphaValue = 0
        previewImage.animator().alphaValue = 0
        
        NSApp.activate(ignoringOtherApps: true)
        
        let prefs = UserDefaults.standard
        
        if let url = prefs.url(forKey: CURRENT_WP_URL) {
            var image: NSImage
            
            titleText.stringValue = prefs.string(forKey: CURRENT_WP_TITLE)!
            bylineText.stringValue = prefs.string(forKey: CURRENT_WP_BYLINE)!
            attributionText.stringValue = prefs.string(forKey: CURRENT_WP_ATTRIBUTION)!

            do {
                try image = NSImage.init(data: Data.init(contentsOf: url, options: []))!
                previewImage.image = image
                
                loadingIndicator.stopAnimation(nil)
                loadingIndicator.isHidden = true
                
                NSAnimationContext.runAnimationGroup({ (context) in
                    context.duration = 1
                    previewImage.alphaValue = 0
                    previewImage.animator().alphaValue = 1
                    
                }, completionHandler: {
                    //empty
                })

                previewImage.shadow = NSShadow()
                previewImage.layer?.shadowColor = NSColor.black.cgColor
                previewImage.layer?.shadowOpacity = 0.5
                previewImage.layer?.shadowOffset = CGSize.zero
                previewImage.layer?.shadowRadius = 5
            }
                
            catch {
                print("Error reading data")
            }
        }

        
    }
}
