//
//  WallpaperSource.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation

class FeaturedArtSource: WPSourceProtocol {

    let API_URL: String = "http://muzeiapi.appspot.com/featured?cachebust=1"
    
    func getWallpaper(callback: (NSURL) -> Void) {
        
        let image = "/Users/naman/Pictures/Irvue/pic1.jpg"
        callback(NSURL.fileURLWithPath(image))
    }
    
}
