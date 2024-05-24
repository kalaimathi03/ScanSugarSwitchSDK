//
//  WebserviceCameraManager.swift
//  scanflowWebserviceSDK
//
//  Created by MAC-OBS-47 on 10/05/24.
//

import Foundation
import ScanflowCore
import UIKit
import CoreVideo
import CoreMedia
import Accelerate
import opencv2

struct BoundingBox {
    var xPosition: Float
    var yPosition: Float
    var width: Float
    var height: Float
}

@objc public enum TireScanningMode: Int {
    case tireSerialNumberScanning
    case tireDotScanning
}

@objc public enum ContainerScanningMode: Int {
    case verticle
    case horizontal
}


@objc(ScanflowTextManager)
public class WebserviceCameraManager: ScanflowCameraManager {
    
    var threadCount = 1
    var resizedBufferImage: UIImage?
    var originalBufferImage: UIImage?
    internal var labels: [String] = []
    
    internal let batchSize = 1
    internal let inputChannels = 3
    internal let inputWidth = 416.0
    internal let inputHeight = 416.0
    
    internal let edgeOffset: CGFloat = 2.0
    internal let labelOffset: CGFloat = 10.0
    internal let animationDuration = 0.5
    internal let collapseTransitionThreshold: CGFloat = -30.0
    internal let expandTransitionThreshold: CGFloat = 30.0
    internal let delayBetweenInferencesMs: Double = 200
    
    
    internal let efficientInputWidth = 224.0
    internal let efficientInputHeight = 224.0
    var timer = Timer()

    // image mean and std for floating model, should be consistent with parameters used in model training
    private let imageMean: Float = 127.5
    private let imageStd:  Float = 127.5
    @objc public var startCapture: Bool = false
    private var resultArray: [String] = []
     var finalResult: String = ""
    internal var dectectionModelPath: String?
    internal var classificationModelPath: String?
//    private var modelType: ModelType?
    internal var containerResult:[String: Float] = [:]
    var tireResult: [String]? = []
     var currentConfidenceLevel: Float?
     var sortedTireResult: UIImage?
    var inProgress: Bool = false
    var predictionArray = ["D0T", "D01", "0T", "001", "00T", "DDT", "DD1", "N01", "OOT", "0O1", "O0T", "DO7", "D07", "DD7", "N07"]
    @objc(init:::::::::)
    public override init(previewView: UIView, scannerMode: ScannerMode, overlayApperance: OverlayViewApperance, overCropNeed: Bool = false, leftTopArc: UIColor = .topLeftArrowColor, leftDownArc: UIColor = .bottomLeftArrowColor, rightTopArc: UIColor = .topRightArrowColor, rightDownArc: UIColor = .bottomRightArrowColor, locationNeed: Bool = false) {
        super.init(previewView: previewView, scannerMode: scannerMode, overlayApperance: overlayApperance, overCropNeed: overCropNeed, leftTopArc: leftTopArc, leftDownArc: leftDownArc, rightTopArc: rightTopArc, rightDownArc: rightDownArc, locationNeed: locationNeed)
        captureDelegate = self
        toBeSendInDelegate = false
     
       
    }

    
    @objc(startCaptureData)
    public func startCaptureData() {
        inProgress = false
            containerResult = [:]
            self.startCapture = true
            DispatchQueue.global().asyncAfter(deadline: .now() + 5, execute: {
                self.stopCaptureData()
            })
        
    }
    
    private func stopCaptureData() {

        isFrameProcessing = false
    }
   
    

}

extension WebserviceCameraManager : CaptureDelegate {
   
    public func readData(originalframe: CVPixelBuffer, croppedFrame: CVPixelBuffer) {
      
        if startCapture == true {

            print("originalimage1", croppedFrame.toImage())
            if scannerType == .sugarcane || scannerType == .switchType{
                self.startCapture = false

                sortedTireResult = croppedFrame.toImage()
                let sortresult = containerResult.sorted(by: { $0.value < $1.value })
                delegate?.capturedOutput(result: sortresult.last?.key ?? "", codeType: scannerType, results: nil, processedImage: croppedFrame.toImage(), location: currentCoordinates)


            }
        }
    }

    
}


