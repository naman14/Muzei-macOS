//
//  AppDelegate.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    @IBOutlet weak var quitItem: NSMenuItem!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusicon")
        icon?.template = true
        statusItem.image = icon
        statusItem.menu = statusMenu
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }


}

