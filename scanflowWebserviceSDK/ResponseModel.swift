//
//  ResponseModel.swift
//  scanflowWebserviceSDK
//
//  Created by MAC-OBS-47 on 30/04/24.
//

import Foundation
import UIKit


struct ImageToData {
    
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/png"
        self.filename = "photo\(arc4random()).png"
        guard let data = image.jpegData(compressionQuality: 0.1) else { return nil }
        self.data = data
    }
    
}

public struct SugarcaneDataModel: Codable {
    // Define properties matching the structure of your API response
    let filename: String?
    let category: String?
    let prediction: String?

    // Add more properties as needed
}
