//
//  MenuController.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Cocoa

class MenuController: NSObject, SourceMenuDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var sourcesMenu: NSMenu!
    
    @IBOutlet weak var quitItem: NSMenuItem!
    @IBOutlet weak var updateItem: NSMenuItem!
    @IBOutlet weak var featuredArtSourceItem: NSMenuItem!
    @IBOutlet weak var redditSourceItem: NSMenuItem!
    @IBOutlet weak var viewWallpaperItem: NSMenuItem!
    @IBOutlet weak var saveWallpaperItem: NSMenuItem!
    @IBOutlet weak var preferencesItem: NSMenuItem!

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var defaults: UserDefaults
    var preferenceController: PreferenceWindowController
    
    var wallpaperWindowController: WallpaperWindowController

    
    override init() {
        defaults = UserDefaults.standard
        preferenceController = PreferenceWindowController(windowNibName: "PreferenceWindow")
        wallpaperWindowController = WallpaperWindowController(windowNibName: "WallpaperWindow")
        super.init()
        preferenceController.setMenuController(controller: self)
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
        updateSource(preferenceController.SOURCE_FEATURED)
    }
    
    @IBAction func redditSourceClicked(_ sender: NSMenuItem) {
        updateSource(preferenceController.SOURCE_REDDIT)
    }
    
    @IBAction func viewWallpaperClicked(_ sender: NSMenuItem) {
        if(wallpaperWindowController.isWindowLoaded) {
            wallpaperWindowController.window?.setIsVisible(true)
            wallpaperWindowController.updateWindow()
        } else {
            wallpaperWindowController.showWindow(self)
        }
    }
    
    @IBAction func saveWallpaperClicked(_ sender: NSMenuItem) {
        if WPProcessor().saveCurrentWallpaper() {
            print("Wallpaper saved")
        } else {
            print("Failed to save wallpaper")
        }
    }
    
    @IBAction func preferenceClicked(_ sender: NSMenuItem) {
        if(preferenceController.isWindowLoaded) {
            preferenceController.window?.setIsVisible(true)
            preferenceController.updateWindow()
        } else {
            preferenceController.showWindow(self)
        }
    }

    
    func setupMenu() {
        let icon = NSImage(named: "statusicon")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        statusMenu.delegate = self
        
    }
    
    func updateSource(_ source: String) {
        defaults.setValue(source, forKey: preferenceController.PREF_SOURCE)
        defaults.synchronize()
        
    }
    

    
    func updateSourceMenuState() {
        
        var menuItem: NSMenuItem
        
        switch getSource()! {
            
        case preferenceController.SOURCE_FEATURED:
            menuItem = featuredArtSourceItem
        case preferenceController.SOURCE_REDDIT:
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
        wallpaperSource.getWallpaper(callback: { wp in
            self.setActiveWorkspaceObserver(wallpaper: wp )
            self.setWallpaper(wallpaper: wp)
        }, failure: {
        
        })
        
    }
    
    func getWallpaperSource()->WPSourceProtocol {
        
        var wpsource: WPSourceProtocol
        
        switch getSource()! {
            
        case preferenceController.SOURCE_FEATURED:
            wpsource = FeaturedArtSource()
        case preferenceController.SOURCE_REDDIT:
            wpsource = RedditSource()
        default:
            wpsource = FeaturedArtSource()
        }
        
        return wpsource
    }
    
    func getSource()->String? {
        
        var source: String? = defaults.string(forKey: preferenceController.PREF_SOURCE)
        
        if source == nil {
            source = preferenceController.SOURCE_FEATURED
        }
        
        return source;

    }
    
    func setWallpaper(wallpaper: Wallpaper) {
        
        do {
            let workspace = NSWorkspace.shared()
            if let screen = NSScreen.main()  {
                try workspace.setDesktopImageURL(wallpaper.processedImageUrl, for: screen, options: [:])
                WPProcessor().deletePreviousWallpaper(current: wallpaper)
                WPProcessor().saveWallpaperDetails(current: wallpaper)
            }
        } catch {
            print(error)
        }
        
       
    }
    
    func setActiveWorkspaceObserver(wallpaper: Wallpaper) {
        
        let workspace = NSWorkspace.shared()
        
        workspace.notificationCenter.addObserver(forName: NSNotification.Name.NSWorkspaceActiveSpaceDidChange, object: nil, queue: nil) { (Notification) in
            
            self.setWallpaper(wallpaper: wallpaper)
    
        }
        
        
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        //empty
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        updateSourceMenuState()

    }
    
    
}
