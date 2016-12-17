//
//  MenuController.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Cocoa

class MenuController: NSObject, SourceMenuDelegate {

    let sourcePreferenceKey = "pref_source"
    let sourceFeaturedArt = "source_featured"
    let sourceReddit = "source_reddit"
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var sourcesMenu: NSMenu!
    
    @IBOutlet weak var quitItem: NSMenuItem!
    @IBOutlet weak var updateItem: NSMenuItem!
    @IBOutlet weak var featuredArtSourceItem: NSMenuItem!
    @IBOutlet weak var redditSourceItem: NSMenuItem!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var defaults: NSUserDefaults
    
    override init() {
        defaults = NSUserDefaults.standardUserDefaults()
        super.init()

    }
    
   override func awakeFromNib() {
        setupMenu()
    
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }

    @IBAction func updateClicked(sender: NSMenuItem) {
        getWallpaper()
    }
    
    @IBAction func featuredArtSourceClicked(sender: NSMenuItem) {
        updateSource(sourceFeaturedArt)
    }
    
    @IBAction func redditSourceClicked(sender: NSMenuItem) {
        updateSource(sourceReddit)
    }
    
    func setupMenu() {
        let icon = NSImage(named: "statusicon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        statusMenu.delegate = self
        
    }
    
    func updateSource(source: String) {
        defaults.setValue(source, forKey: sourcePreferenceKey)
        defaults.synchronize()
        
    }
    

    
    func updateSourceMenuState() {
        
        var menuItem: NSMenuItem
        
        switch getSource()! {
            
        case sourceFeaturedArt:
            menuItem = featuredArtSourceItem
        case sourceReddit:
            menuItem = redditSourceItem
        default:
            menuItem = featuredArtSourceItem
            
        }
        
        for item in sourcesMenu.itemArray {
            item.state = NSOffState
        }
        
         menuItem.state = NSOnState
        
    }

    
    func getWallpaper() {
        let wallpaperSource = self.getWallpaperSource()
        wallpaperSource.getWallpaper({ url in
            print(url)
            self.setWallpaper(url)
        })
        
    }
    
    func getWallpaperSource()->WPSourceProtocol {
        
        var wpsource: WPSourceProtocol
        
        switch getSource()! {
            
        case sourceFeaturedArt:
            wpsource = FeaturedArtSource()
        case sourceReddit:
            wpsource = RedditSource()
        default:
            wpsource = FeaturedArtSource()
        }
        
        return wpsource
    }
    
    func getSource()->String? {
        
        var source: String? = defaults.stringForKey(sourcePreferenceKey)
        
        if source == nil {
            source = sourceFeaturedArt
        }
        
        return source;

    }
    
    func setWallpaper(url: NSURL) {
        
        do {
            let workspace = NSWorkspace.sharedWorkspace()
            if let screen = NSScreen.mainScreen()  {
                try workspace.setDesktopImageURL(url, forScreen: screen, options: [:])
            }
        } catch {
            print(error)
        }
        
       
    }
    
    func menuWillOpen(menu: NSMenu) {
        //empty
    }
    
    func menuNeedsUpdate(menu: NSMenu) {
        updateSourceMenuState()

    }
    
    
}
