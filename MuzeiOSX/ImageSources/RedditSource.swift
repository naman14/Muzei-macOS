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

class RedditSource: WallpaperSourceProtocol {
    
    let PREF_SUBREDDIT = "pref_subreddit"
    
    var base_url = "https://www.reddit.com/r/{subreddit}/top.json?t=week&limit=10&raw_json=1"
    
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
                
                if (children.isEmpty) {
                    failure()
                    print("No images found")
                    return
                }
                
                //roughly check if its a landscape image before setting, try to ignore portrait image upto 3 times
                var tries = 0
                
                let totalCount = children.count
                var random = Int(arc4random_uniform(UInt32(totalCount)))
                var data = children[random]["data"]
                var imageSource = data["preview"]["images"][0]["source"]
                
                while (tries <= 3 && imageSource["width"].intValue > imageSource["height"].intValue) {
                    random = Int(arc4random_uniform(UInt32(totalCount)))
                    data = children[random]["data"]
                    imageSource = data["preview"]["images"][0]["source"]
                    tries += 1
                }
                
                let title = data["title"].stringValue
    
                let source = imageSource
                
                let imageUri = source["url"].stringValue
                let byline = data["subreddit"].stringValue
                let attribution = data["domain"].stringValue
                let detailsUri = data["url"].stringValue
                
                if(ImageCache.default.imageCachedType(forKey: title).cached) {
                    
                    ImageCache.default.retrieveImage(forKey: title, options: nil) {
                        image, cacheType in
                        if let image = image {
                            
                            let random = 2 + Int(arc4random_uniform(UInt32(999 - 2 + 1)))
                            
                            let trimmedUrl =  NSURL(string: imageUri)?.absoluteStringByTrimmingQuery()
                            
                            let fullURL = WallpaperProcessor().getWallpaperFileUrl(
                                fileName: (trimmedUrl! as NSString).lastPathComponent as NSString, processed: false, random: random)
                            
                            if WallpaperProcessor().imageToFile(image: image, imageURL: fullURL!, ext:(trimmedUrl! as NSString).pathExtension) {
                                
                                let processedImage = WallpaperProcessor().processImage(originalImage: image)
                                
                                let processedURL = WallpaperProcessor().getWallpaperFileUrl(
                                    fileName: (trimmedUrl! as NSString).lastPathComponent as NSString, processed: true, random: random)
                                
                                if WallpaperProcessor().imageToFile(image: processedImage, imageURL: processedURL!, ext:(trimmedUrl! as NSString).pathExtension) {
                                    
                                    let wp: Wallpaper = Wallpaper(title: title,imageUrl: fullURL!, processedUrl: processedURL!)
                                    
                                    wp.byline = byline
                                    wp.attribution = attribution
                                    wp.detailsUri = detailsUri
                                    
                                    callback(wp)
                                    
                                } else {
                                    failure()
                                    print("Error occurred")
                                    
                                }
                                
                                
                            } else {
                                failure()
                                print("Error occurred")
                                
                            }
                            
                            
                        } else {
                            print("Not exist in cache.")
                        }
                    }
                    
                } else {
                    ImageDownloader.default.downloadImage(with: URL(string: imageUri)!) {
                        (image, error, url, data) in
                        
                        if (error != nil) {
                            failure()
                            print(error?.description ?? "Error occurred")
                            return
                        }
                        
                        let random = 2 + Int(arc4random_uniform(UInt32(999 - 2 + 1)))
                        
                        let trimmedUrl =  NSURL(string: imageUri)?.absoluteStringByTrimmingQuery()
                        
                        
                        let fullURL = WallpaperProcessor().getWallpaperFileUrl(
                            fileName: (trimmedUrl! as NSString).lastPathComponent as NSString, processed: false, random: random)
                        
                        if WallpaperProcessor().imageToFile(image: image!, imageURL: fullURL!, ext:(trimmedUrl! as NSString).pathExtension) {
                            
                            let processedImage = WallpaperProcessor().processImage(originalImage: image!)
                            
                            let processedURL = WallpaperProcessor().getWallpaperFileUrl(
                                fileName: (trimmedUrl! as NSString).lastPathComponent as NSString, processed: true, random: random)
                            
                            if WallpaperProcessor().imageToFile(image: processedImage, imageURL: processedURL!, ext:(trimmedUrl! as NSString).pathExtension) {
                                
                                let wp: Wallpaper = Wallpaper(title: title,imageUrl: fullURL!, processedUrl: processedURL!)
                                ImageCache.default.store(image!, forKey: title)
                                
                                wp.byline = byline
                                wp.attribution = attribution
                                wp.detailsUri = detailsUri

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
}






