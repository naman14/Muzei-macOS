//
//  WallpaperSource.swift
//  MuzeiOSX
//
//  Created by Naman on 16/12/16.
//  Copyright © 2016 naman14. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher

class FeaturedArtSource: WPSourceProtocol {

    let API_URL: String = "https://muzeiapi.appspot.com/featured?cachebust=1"
    
    func getWallpaper(callback: @escaping (Wallpaper) -> Void,  failure: @escaping () -> Void) {
        
        Alamofire.request(API_URL).responseJSON { response in
            if let responseStr = response.result.value {
                
                let json = JSON(responseStr)
                
                let imageUri: String = json["imageUri"].stringValue
                let title: String = json["title"].stringValue
            
                let httpsUri = imageUri.replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)

                ImageDownloader.default.downloadImage(with: URL(string: httpsUri)!, options: [], progressBlock: nil) {
                    (image, error, url, data) in
                    
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                    
                    let fullURL = WPProcessor().getWallpaperFileUrl(
                        fileName: (imageUri as NSString).lastPathComponent as NSString, processed: false)
                    
                    if WPProcessor().imageToFile(image: image!, imageURL: fullURL!, ext:(imageUri as NSString).pathExtension) {
                        
                        let processedImage = WPProcessor().processImage(originalImage: image!)
                        
                        let processedURL = WPProcessor().getWallpaperFileUrl(
                            fileName: (imageUri as NSString).lastPathComponent as NSString, processed: true)
                        
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
