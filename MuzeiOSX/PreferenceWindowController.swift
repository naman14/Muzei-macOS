//
//  PreferenceWindowController.swift
//  MuzeiOSX
//
//  Created by Naman on 31/01/17.
//  Copyright © 2017 naman14. All rights reserved.
//

import Foundation
import Cocoa
import Kingfisher

class PreferenceWindowController : NSWindowController {
    
    @IBOutlet weak var sourceFeaturedArt: NSButton!
    @IBOutlet weak var sourceReddit: NSButton!
    @IBOutlet weak var textSubredditName: NSTextField!
    @IBOutlet weak var sourceDone: NSButton!
    
    @IBOutlet weak var blurButton: NSButton!
    @IBOutlet weak var dimButton: NSButton!
    @IBOutlet weak var blurSlider: NSSlider!
    @IBOutlet weak var dimSlider: NSSlider!
    @IBOutlet weak var wallpaperDone: NSButton!
    @IBOutlet weak var showInfoButton: NSButton!
    
    @IBOutlet weak var previewImage: NSImageView!
    let SOURCE_FEATURED = "source_featured_art"
    let SOURCE_REDDIT = "source_reddit"
    
    let PREF_SOURCE = "pref_source"
    let PREF_SUBREDDIT = "pref_subreddit"
    
    let CURRENT_WP_URL = "current_wallpaper_url"
    let PREF_BLUR_ACTIVE = "pref_blur_active"
    let PREF_DIM_ACTIVE = "pref_dim_active"
    let PREF_BLUR_AMOUNT = "pref_blur_amount"
    let PREF_DIM_AMOUNT = "pref_dim_amount"
    let PREF_SHOW_WP_LAUNCH_INACTIVE = "pref_show_wp_launch"

    let prefs = UserDefaults.standard
    
    var menuController: MenuController?
    
    override func windowDidLoad() {
        window?.title = "Preferences"
        updateWindow()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
    
    func setMenuController(controller: MenuController) {
        self.menuController = controller
    }
    
    @IBAction func featuredArtSelected(_ sender: NSButton) {
        updateSource(source: SOURCE_FEATURED)
    }
    
    @IBAction func redditSelected(_ sender: NSButton) {
        updateSource(source: SOURCE_REDDIT)
    }
    
    
    @IBAction func sourceDoneClicked(_ sender: NSButton) {
        prefs.set(textSubredditName.stringValue, forKey: PREF_SUBREDDIT)
        prefs.synchronize()
        window?.close()
    }
    
    @IBAction func blurButtonClicked(_ sender: NSButton) {
        blurSlider.isEnabled = (sender.state ==  NSOnState)
        prefs.set(sender.state == NSOnState, forKey: PREF_BLUR_ACTIVE)
        prefs.synchronize()
        updatePreviewImage()
    }
    
    @IBAction func dimButtonClicked(_ sender: NSButton) {
        dimSlider.isEnabled = (sender.state ==  NSOnState)
        prefs.set(sender.state == NSOnState, forKey: PREF_DIM_ACTIVE)
        prefs.synchronize()
        updatePreviewImage()
    }
    
    @IBAction func showInfoClicked(_ sender: NSButton) {
        prefs.set(sender.state == NSOffState, forKey: PREF_SHOW_WP_LAUNCH_INACTIVE)
        prefs.synchronize()
    }
    
    @IBAction func wallpaperDoneClicked(_ sender: NSButton) {
        prefs.set(blurSlider.floatValue, forKey: PREF_BLUR_AMOUNT)
        prefs.set(dimSlider.floatValue, forKey: PREF_DIM_AMOUNT)
        prefs.synchronize()
        menuController?.getWallpaper()
        window?.close()
    }
    
    @IBAction func blurAmountChanged(_ sender: NSSlider) {
        updatePreviewImage()
    }
    
    @IBAction func dimAmountChanged(_ sender: NSSlider) {
        updatePreviewImage()
    }
    
    func updateWindow() {
        NSApp.activate(ignoringOtherApps: true)
        

        if let source = prefs.string(forKey: PREF_SOURCE) {
            updateSource(source: source)
        } else {
            updateSource(source: SOURCE_FEATURED)
        }
        
        if let subreddit = prefs.string(forKey: PREF_SUBREDDIT) {
            textSubredditName.stringValue = subreddit
        } else {
            textSubredditName.stringValue = "EarthPorn"
        }
        
        blurButton.state = prefs.bool(forKey: PREF_BLUR_ACTIVE) == true ? NSOnState : NSOffState
        dimButton.state = prefs.bool(forKey: PREF_DIM_ACTIVE) == true ? NSOnState : NSOffState
        
        blurSlider.isEnabled = (blurButton.state ==  NSOnState)
        dimSlider.isEnabled = (dimButton.state ==  NSOnState)

        
        blurSlider.floatValue = prefs.float(forKey: PREF_BLUR_AMOUNT) != 0 ? prefs.float(forKey: PREF_BLUR_AMOUNT) : 15
        dimSlider.floatValue = prefs.float(forKey: PREF_DIM_AMOUNT) != 0 ? prefs.float(forKey: PREF_DIM_AMOUNT) : 0.2
        
        showInfoButton.state = !prefs.bool(forKey: PREF_SHOW_WP_LAUNCH_INACTIVE) ? NSOnState : NSOffState
        
        updatePreviewImage()
        
        previewImage.shadow = NSShadow()
        previewImage.layer?.shadowColor = NSColor.black.cgColor
        previewImage.layer?.shadowOpacity = 0.5
        previewImage.layer?.shadowOffset = CGSize.zero
        previewImage.layer?.shadowRadius = 5
    }
    
    func updateSource(source: String) {
        prefs.set(source, forKey: PREF_SOURCE)

        switch(source) {
            
        case SOURCE_FEATURED:
            sourceReddit.state = NSOffState
            sourceFeaturedArt.state = NSOnState
            textSubredditName.isEnabled = false
            break
            
        case SOURCE_REDDIT:
            sourceReddit.state = NSOnState
            sourceFeaturedArt.state = NSOffState
            textSubredditName.isEnabled = true
            break
            
        default: break
            
        }
        prefs.synchronize()
    }
    
    func updatePreviewImage() {
        
        if let url = prefs.url(forKey: CURRENT_WP_URL) {
            
            var processor: ImageProcessor?
            
            if(prefs.bool(forKey: PREF_BLUR_ACTIVE)) {
                let blurProcessor = BlurImageProcessor(blurRadius: CGFloat(blurSlider.floatValue))
                processor = blurProcessor
            }
            
            if(prefs.bool(forKey: PREF_DIM_ACTIVE)) {
                
                let dimColor: NSColor = NSColor(red:CGFloat(0), green:CGFloat(0), blue:CGFloat(0), alpha:CGFloat(1.0))
                
                let dimProcessor = OverlayImageProcessor(overlay: dimColor, fraction: CGFloat(1.0) - CGFloat(dimSlider.floatValue))
                
                if(processor != nil) {
                    processor = processor! >> dimProcessor
                }
                else {
                    processor = dimProcessor
                }
                
            }
            
            if(processor != nil) {
                previewImage.kf.setImage(with: url, placeholder: nil, options: [.processor(processor!)])
            } else {
                previewImage.kf.setImage(with: url)            }
            
        }
        
    }
    
}
