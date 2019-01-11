//
//  UnsplashSource.swift
//  MuzeiOSX
//
//  Created by Lukas Wolfsteiner on 06.01.19.
//  Copyright © 2019 naman14. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher

class UnsplashSource: WallpaperSourceProtocol {
    
    let API_URL: String = "https://api.unsplash.com/photos/random?client_id=YOUR_ACCESS_KEY"
    
    func getWallpaper(callback: @escaping (Wallpaper) -> Void,  failure: @escaping () -> Void) {
        
        Alamofire.request(API_URL).responseJSON { response in
            if let responseStr = response.result.value {
                
                let json = JSON(responseStr)
                
                let imageUri: String = json["urls"]["raw"].stringValue
                let title: String = json["description"].stringValue
                
                let byline = json["user"]["name"].stringValue
                let attribution = json["user"]["portfolio_url"].stringValue
                let detailsUri = json["links"]["html"].stringValue
                
                let httpsUri = imageUri.replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)
                
                
                if(ImageCache.default.imageCachedType(forKey: title).cached) {
                    ImageCache.default.retrieveImage(forKey: title, options: nil) {
                        image, cacheType in
                        if let image = image {
                            
                            let random = 2 + Int(arc4random_uniform(UInt32(999 - 2 + 1)))
                            
                            let fileName: NSString = (imageUri as NSString).lastPathComponent as NSString
                            
                            let fullURL = WallpaperProcessor().getWallpaperFileUrl(
                                fileName: fileName, processed: false, random: random)
                            
                            if WallpaperProcessor().imageToFile(image: image, imageURL: fullURL!, ext:"jpeg") {
                                
                                let processedImage = WallpaperProcessor().processImage(originalImage: image)
                                
                                let processedURL = WallpaperProcessor().getWallpaperFileUrl(
                                    fileName: fileName, processed: true, random: random)
                                
                                if WallpaperProcessor().imageToFile(image: processedImage, imageURL: processedURL!, ext:"jpeg") {
                                    
                                    let wp: Wallpaper = Wallpaper(title: title,imageUrl: fullURL!, processedUrl: processedURL!)
                                    
                                    wp.byline = byline
                                    wp.attribution = attribution
                                    wp.detailsUri = detailsUri
                                    
                                    callback(wp)
                                    
                                } else {
                                    failure()
                                    print("Error occurred: Couldn't download image to file. (1)")
                                }
                                
                                
                            } else {
                                failure()
                                print("Error occurred: Couldn't download image to file. (2)")
                            }
                            
                            
                        } else {
                            print("Not exist in cache.")
                        }
                    }
                } else {
                    
                    ImageDownloader.default.downloadImage(with: URL(string: httpsUri)!, options: [], progressBlock: nil) {
                        (image, error, url, data) in
                        
                        if (error != nil) {
                            failure()
                            print(error?.description ?? "Error occurred: Error description is nil.")
                            return
                        }
                        
                        let random = 2 + Int(arc4random_uniform(UInt32(999 - 2 + 1)))
                        
                        let fileName: NSString = (imageUri as NSString).lastPathComponent as NSString
                        
                        let fullURL = WallpaperProcessor().getWallpaperFileUrl(
                            fileName: fileName, processed: false, random: random)
                        
                        if WallpaperProcessor().imageToFile(image: image!, imageURL: fullURL!, ext:"jpeg") {
                            
                            let processedImage = WallpaperProcessor().processImage(originalImage: image!)
                            
                            let processedURL = WallpaperProcessor().getWallpaperFileUrl(
                                fileName: fileName, processed: true, random: random)
                            
                            if WallpaperProcessor().imageToFile(image: processedImage, imageURL: processedURL!, ext:"jpeg") {
                                
                                let wp: Wallpaper = Wallpaper(title: title,imageUrl: fullURL!, processedUrl: processedURL!)
                                
                                wp.byline = byline
                                wp.attribution = attribution
                                wp.detailsUri = detailsUri
                                
                                ImageCache.default.store(image!, forKey: title)
                                
                                callback(wp)
                                
                            } else {
                                failure()
                                print("Error occurred: While converting image to file. (1)")
                                
                            }
                            
                            
                        } else {
                            failure()
                            print("Error occurred: While converting image to file. (2) uri=\(httpsUri)")
                            
                        }
                        
                        
                    }
                }
                
            }
        }
        
        
    }
    
}
