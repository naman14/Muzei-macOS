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

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var defaults: UserDefaults
    
    override init() {
        defaults = UserDefaults.standard
        super.init()

    }
    
   override func awakeFromNib() {
        setupMenu()
    
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

    @IBAction func updateClicked(_ sender: NSMenuItem) {
        getWallpaper()
    }
    
    @IBAction func featuredArtSourceClicked(_ sender: NSMenuItem) {
        updateSource(sourceFeaturedArt)
    }
    
    @IBAction func redditSourceClicked(_ sender: NSMenuItem) {
        updateSource(sourceReddit)
    }
    
    func setupMenu() {
        let icon = NSImage(named: "statusicon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        statusMenu.delegate = self
        
    }
    
    func updateSource(_ source: String) {
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
        
        for item in sourcesMenu.items {
            item.state = NSOffState
        }
        
         menuItem.state = NSOnState
        
    }

    
    func getWallpaper() {
        let wallpaperSource = self.getWallpaperSource()
        wallpaperSource.getWallpaper(callback: { url in
            print(url)
            self.setWallpaper(url: url)
        }, failure: {
        
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
        
        var source: String? = defaults.string(forKey: sourcePreferenceKey)
        
        if source == nil {
            source = sourceFeaturedArt
        }
        
        return source;

    }
    
    func setWallpaper(url: URL) {
        
        do {
            let workspace = NSWorkspace.shared()
            if let screen = NSScreen.main()  {
                try workspace.setDesktopImageURL(url, for: screen, options: [:])
            }
        } catch {
            print(error)
        }
        
       
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        //empty
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        updateSourceMenuState()

    }
    
    
}
