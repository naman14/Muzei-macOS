//
//  HoverButton.swift
//  MuzeiOSX
//
//  Created by Naman on 07/02/17.
//  Copyright © 2017 naman14. All rights reserved.
//

import Cocoa

class HoverButton: NSButton{
 
    fileprivate var hovered: Bool = false
    
    override var wantsUpdateLayer:Bool{
        return true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    func commonInit(){
        self.wantsLayer = true
        self.createTrackingArea()
        self.hovered = false
    }
    
    fileprivate var trackingArea: NSTrackingArea!
    func createTrackingArea(){
        if(self.trackingArea != nil){
            self.removeTrackingArea(self.trackingArea!)
        }
        let circleRect = self.bounds
        let flag = NSTrackingAreaOptions.mouseEnteredAndExited.rawValue + NSTrackingAreaOptions.activeInActiveApp.rawValue
        self.trackingArea = NSTrackingArea(rect: circleRect, options: NSTrackingAreaOptions(rawValue: flag), owner: self, userInfo: nil)
        self.addTrackingArea(self.trackingArea)
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        self.hovered = true
        self.needsDisplay = true
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        self.hovered = false
        self.needsDisplay = true
    }
    
    override func updateLayer() {
        if(hovered){
            self.alphaValue = 0.6
            
            self.shadow = NSShadow()
            self.layer?.shadowColor = NSColor.black.cgColor
            self.layer?.shadowOpacity = 0.5
            self.layer?.shadowOffset = CGSize.zero
            self.layer?.shadowRadius = 5
        }
        else {
            self.alphaValue = 1
            
            self.shadow = nil

            
        }
        
    }
}
