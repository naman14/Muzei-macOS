//
//  WallpaperSource.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation

class WallpaperSource {
    
    func getWallpaper()->NSURL {
        let image = "/Users/naman/Pictures/Irvue/pic1.jpg"

    
        return NSURL.fileURLWithPath(image)
    }
    
}
