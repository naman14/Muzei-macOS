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
                
                let imageUri = json["imageUri"].stringValue
            
                let httpsUri = String(imageUri).replacingOccurrences(of: "http://", with: "https://", options: .literal, range: nil)

                ImageDownloader.default.downloadImage(with: URL(string: httpsUri)!, options: [], progressBlock: nil) {
                    (image, error, url, data) in
                    
                    let processor = BlurImageProcessor(blurRadius: 4)
                    let processedImage = processor.process(item: ImageProcessItem.image(image!),
                                                             options: [])
                    
                    let processedData = processedImage?.tiffRepresentation
                    
                    if (error != nil) {
                        failure()
                        print(error?.description ?? "Error occurred")
                        return
                    }
                    
                  let fullURL = WPProcessor().getTempFileUrl()
                    
                    do {
                        try processedData?.write(to: fullURL)
                        
                        callback(fullURL)

                        try FileManager.default.removeItem(at: fullURL)
                        
                        
                    } catch {
                        failure()
                        print("Error occurred")
                    }

                }
                
            }
        }
        
       
    }
    
}
