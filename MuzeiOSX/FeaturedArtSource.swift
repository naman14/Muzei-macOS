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
            print(response.result)   // result of response serialization
            
            if let responseStr = response.result.value {
                print("JSON: \(responseStr)")
                
                let json = JSON(responseStr)
                
                let imageUri = json["imageUri"].stringValue
            
                let httpsUri = String(imageUri).replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)

                
                ImageDownloader.default.downloadImage(with: URL(string: httpsUri)!, options: [], progressBlock: nil) {
                    (image, error, url, data) in
                    
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                    
                    let directory = NSTemporaryDirectory()
                    let fileName = UUID().uuidString
                    
                    let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
                    
                    
                    print("Downloaded Image: \(image)")
                    
                    do {
                        try data?.write(to: fullURL!)
                    
                    } catch {
                        
                    }

                    callback(fullURL!)

                }
                
            }
        }
        
       
    }
    
}
