//
//  RedditSource.swift
//  MuzeiOSX
//
//  Created by Naman on 17/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import Kingfisher

class RedditSource: WPSourceProtocol {
    
    let PREF_SUBREDDIT = "pref_subreddit"

    var base_url = "https://www.reddit.com/r/{subreddit}/top.json?t=day&limit=10"
    
    func getWallpaper(callback: @escaping (Wallpaper) -> Void, failure: @escaping () -> Void) {
        
        let prefs = UserDefaults.standard
        
        if let subreddit = prefs.string(forKey: PREF_SUBREDDIT) {
            base_url = base_url.replacingOccurrences(of: "{subreddit}", with: subreddit)
        } else {
            base_url = base_url.replacingOccurrences(of: "{subreddit}", with: "EarthPorn")

        }
        
        Alamofire.request(base_url).responseJSON { (response) in
            
            if let responseStr = response.result.value {
                let json = JSON(responseStr)
                
                let children = json["data"]["children"].arrayValue
                
                let data = children[0]["data"]
                
                let title = data["title"].stringValue
                
                let source = data["preview"]["images"][0]["source"]
                
                let imageUri = source["url"].stringValue
                let width = source["width"].intValue
                let height = source["height"].intValue
                
                ImageDownloader.default.downloadImage(with: URL(string: imageUri)!) {
                    (image, error, url, data) in
                    
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                    
                    let random = 2 + Int(arc4random_uniform(UInt32(999 - 2 + 1)))

                    
                    let fullURL = WPProcessor().getWallpaperFileUrl(
                        fileName: (imageUri as NSString).lastPathComponent as NSString, processed: false, random: random)
                    
                    if WPProcessor().imageToFile(image: image!, imageURL: fullURL!, ext:(imageUri as NSString).pathExtension) {
                        
                        let processedImage = WPProcessor().processImage(originalImage: image!)
                        
                        let processedURL = WPProcessor().getWallpaperFileUrl(
                            fileName: (imageUri as NSString).lastPathComponent as NSString, processed: true, random: random)
                        
                        if WPProcessor().imageToFile(image: processedImage, imageURL: processedURL!, ext:(imageUri as NSString).pathExtension) {
                            
                            let wp: Wallpaper = Wallpaper(title: title,imageUrl: fullURL!, processedUrl: processedURL!)
                            
                            callback(wp)
                            
                        } else {
                            failure()
                            print("Error occurred")
                            
                        }
                        
                        
                    } else {
                        failure()
                        print("Error occurred")
                        
                    }
                    
                }
                
            }
        }
        
        
    }
}






