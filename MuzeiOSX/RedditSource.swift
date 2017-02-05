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
    
    let BASE_URL = "https://www.reddit.com/r/earthporn/top.json?t=day&limit=10"
    
    func getWallpaper(callback: @escaping (URL) -> Void, failure: @escaping () -> Void) {
        
        Alamofire.request(BASE_URL).responseJSON { (response) in
            
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
                    
                    let processedImage = WPProcessor().processImage(originalImage: image!)
                    
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                    
                    let fullURL = WPProcessor().getWallpaperFileUrl(
                        fileName: (imageUri as NSString).lastPathComponent as NSString)
                    print(fullURL)
                    if WPProcessor().imageToFile(image: processedImage, imageURL: fullURL!, ext:(imageUri as NSString).pathExtension) {
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






