//
//  HoverButton.swift
//  MuzeiOSX
//
//  Created by Naman on 07/02/17.
//  Copyright © 2017 naman14. All rights reserved.
//

import Cocoa

class HoverButton: NSButton{
    var backgroundColor: NSColor?
    var hoveredBackgroundColor: NSColor?
    var pressedBackgroundColor: NSColor?
    
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
        self.hoveredBackgroundColor = NSColor.selectedTextBackgroundColor
        self.pressedBackgroundColor = NSColor.selectedTextBackgroundColor
        self.backgroundColor = NSColor.clear
        
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
            if (self.cell!.isHighlighted){
                self.layer?.cornerRadius = 15.0
                self.layer?.borderColor = pressedBackgroundColor?.cgColor
                self.layer?.borderWidth = 2
                
            }
            else{
                self.layer?.cornerRadius = 15.0
                self.layer?.borderColor = hoveredBackgroundColor?.cgColor
                self.layer?.borderWidth = 2
                
            }
        }
        else{
            self.layer?.backgroundColor = backgroundColor?.cgColor
            self.layer?.borderWidth = 0
            
        }
        
    }
}
