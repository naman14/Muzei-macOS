//
//  MenuController.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Cocoa

class MenuController: NSObject {

    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var quitItem: NSMenuItem!
    @IBOutlet weak var updateItem: NSMenuItem!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var wallpaperSource: WPSourceProtocol
    
    override init() {
        
        let source: String = "featured"
        
        switch source {
            
        case "featured":
            wallpaperSource = FeaturedArtSource()
        default:
            wallpaperSource = FeaturedArtSource()
        }

    }
    
   override func awakeFromNib() {
        let icon = NSImage(named: "statusicon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
    
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    @IBAction func updateClicked(sender: NSMenuItem) {
        setWallpaper()
    }

    func setWallpaper() {
        
        let imgUrl = wallpaperSource.getWallpaper()
        print(imgUrl)
        
        do {
            let workspace = NSWorkspace.sharedWorkspace()
            if let screen = NSScreen.mainScreen()  {
                try workspace.setDesktopImageURL(imgUrl, forScreen: screen, options: [:])
            }
        } catch {
            print(error)
        }
        
       
    }

}
