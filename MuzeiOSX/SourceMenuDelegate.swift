//
//  SourceMenuDelegate.swift
//  MuzeiOSX
//
//  Created by Naman on 17/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation
import Cocoa

@objc protocol SourceMenuDelegate: NSMenuDelegate {
    
    func menuWillOpen(menu: NSMenu)
    
    func menuNeedsUpdate(menu: NSMenu)
    
    optional func menuDidClose(menu: NSMenu)
    
    optional func menuHasKeyEquivalent(menu: NSMenu, forEvent event: NSEvent, target: AutoreleasingUnsafeMutablePointer<AnyObject?>, action: UnsafeMutablePointer<Selector>) -> Bool
    
    optional func menu(menu: NSMenu, willHighlightItem item: NSMenuItem?)
    
    optional func menu(menu: NSMenu, updateItem item: NSMenuItem, atIndex index: Int, shouldCancel: Bool) -> Bool
  
}
