//
//  WebserviceCaptureSession.swift
//  scanflowWebserviceSDK
//
//  Created by MAC-OBS-47 on 30/04/24.
//

import Foundation
import UIKit



// Define a protocol to handle API responses
public protocol APIDataDelegate: AnyObject {
    func didReceiveData(_ data: Data)
    func didFailWithError(_ error: Error)
}


public class WebserviceSDK {
    
    public weak var delegate: APIDataDelegate?
    
      internal init() {
          // Initialization code
      }

      public static func createInstance() -> WebserviceSDK {
          return WebserviceSDK()
      }

    
    public func getSugarcaneOrSwitchData(type:String,image:UIImage) {
              
        var urlString = ""
        if type == "Switch"{
            
            urlString = "https://scanflowqc.scanflow.ai/upload?input_text=model_y"
        }
        else{
            urlString = "https://scanflowgrading.scanflow.ai/predict"
        }
        let imageData = ImageToData(withImage: image, forKey: "file")
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let dataBody = createDataBody(media: imageData, boundary: boundary)
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else { return }
           
            if let error = error {
                self.delegate?.didFailWithError(error)
                return
            }
            guard let responseData = data else {
                let error = NSError(domain: "com.example.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                self.delegate?.didFailWithError(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let myData = try decoder.decode(SugarcaneDataModel.self, from: responseData)
                self.delegate?.didReceiveData(data!)
            } catch {
                self.delegate?.didFailWithError(error)
            }
            
        }.resume()
        
    }
    
    func createDataBody(media: ImageToData?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        if let media = media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename= \"\(media.filename)\"\(lineBreak)")
            body.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)")
            body.append(media.data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

