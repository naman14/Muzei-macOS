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
    
    func getWallpaper(callback: @escaping (URL) -> Void,  failure: @escaping () -> Void) {
        
        Alamofire.request(API_URL).responseJSON { response in
            if let responseStr = response.result.value {
                
                let json = JSON(responseStr)
                
                let imageUri: String = json["imageUri"].stringValue
            
                let httpsUri = imageUri.replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)

                ImageDownloader.default.downloadImage(with: URL(string: httpsUri)!, options: [], progressBlock: nil) {
                    (image, error, url, data) in
                    
                   let processedImage = image
                                        
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                
                  let fullURL = WPProcessor().getWallpaperFileUrl(
                    fileName: (imageUri as NSString).lastPathComponent as NSString)
                    if WPProcessor().imageToFile(image: processedImage!, imageURL: fullURL!, ext:(imageUri as NSString).pathExtension) {
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
