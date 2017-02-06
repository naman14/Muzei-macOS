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
    
    func getWallpaper(callback: @escaping (URL) -> Void, failure: @escaping () -> Void) {
        
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
                    
                    let processedImage = image
                    
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                    
                    let trimmedUrl =  NSURL(string: imageUri)?.absoluteStringByTrimmingQuery()

                    let fullURL = WPProcessor().getWallpaperFileUrl(
                        fileName: (trimmedUrl! as NSString).lastPathComponent as NSString)
                    
                    if WPProcessor().imageToFile(image: processedImage!, imageURL: fullURL!, ext:((trimmedUrl)?.pathExtension)!) {
                        callback(fullURL!)
                    } else {
                        failure()
                        print("Error occurred2")
                        
                    }
                    
                }
                
            }
        }
        
        
    }
}






