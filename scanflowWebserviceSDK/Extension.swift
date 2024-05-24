//
//  Extension.swift
//  scanflowWebserviceSDK
//
//  Created by MAC-OBS-47 on 30/04/24.
//

import Foundation


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
