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
    
    func menuWillOpen(_ menu: NSMenu)
    
    func menuNeedsUpdate(_ menu: NSMenu)
    
    @objc optional func menuDidClose(_ menu: NSMenu)
    
    @objc optional func menuHasKeyEquivalent(_ menu: NSMenu, forEvent event: NSEvent, target: AutoreleasingUnsafeMutablePointer<AnyObject?>, action: UnsafeMutablePointer<Selector>) -> Bool
    
    @objc optional func menu(_ menu: NSMenu, willHighlightItem item: NSMenuItem?)
    
    @objc optional func menu(_ menu: NSMenu, updateItem item: NSMenuItem, atIndex index: Int, shouldCancel: Bool) -> Bool
  
}
