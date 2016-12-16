//
//  RedditSource.swift
//  MuzeiOSX
//
//  Created by Naman on 17/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation

class RedditSource: WPSourceProtocol {
    
    
    func getWallpaper()-> NSURL {
        
        let image = "/Users/naman/Pictures/Irvue/pic1.jpg"
        return NSURL.fileURLWithPath(image)
}

}

