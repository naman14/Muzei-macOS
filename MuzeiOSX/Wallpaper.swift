//
//  Wallpaper.swift
//  MuzeiOSX
//
//  Created by Naman on 06/02/17.
//  Copyright © 2017 naman14. All rights reserved.
//

import Foundation

class Wallpaper {
    
    var title: String
    var imageUrl: URL
    var processedImageUrl: URL
    
    var byline: String = ""
    var attribution: String = ""
    var detailsUri: String = ""
    
    init(title: String, imageUrl: URL, processedUrl: URL) {
        self.title = title
        self.imageUrl = imageUrl
        self.processedImageUrl = processedUrl
    }
}
