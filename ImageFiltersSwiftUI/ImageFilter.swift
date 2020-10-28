//
//  ImageFilter.swift
//  ImageFiltersSwiftUI
//
//  Created by Gregory Berngardt on 22.10.2020.
//

import UIKit

public enum ImageFilter: String, CaseIterable {
    case original = ""
    case chrome = "CIPhotoEffectChrome"
    case fade = "CIPhotoEffectFade"
    case instant = "CIPhotoEffectInstant"
    case mono = "CIPhotoEffectMono"
    case noir = "CIPhotoEffectNoir"
    case process = "CIPhotoEffectProcess"
    case tonal = "CIPhotoEffectTonal"
    case transfer = "CIPhotoEffectTransfer"
        
    var name: String {
        switch self {
        case .original:
            return "original"
        case .chrome:
            return "chrome"
        case .fade:
            return "fade"
        case .instant:
            return "instant"
        case .mono:
            return "mono"
        case .noir:
            return "noir"
        case .process:
            return "process"
        case .tonal:
            return "tonal"
        case .transfer:
            return "transfer"
        }
    }
    
    /// Возвращает все фильтры, кроме оригинального
    public static var filters: [ImageFilter] {
        return allCases.filter { $0 != .original }
    }
}

struct FilterApplyer {
    
    public static let shared = FilterApplyer()
    
    private let context = CIContext()
    
    func apply(_ filter: ImageFilter, to image: UIImage, size: CGSize? = nil) -> UIImage? {
        guard filter != .original else {
            return image
        }
        guard let filter = CIFilter(name: filter.rawValue) else {
            return nil
        }
        
        let resultSize = { () -> CGSize in
            if let size = size {
                return size
            } else {
                return image.size
            }
        }()
        
        let minScale = min(resultSize.width / image.size.width, resultSize.height / image.size.height)
        
        let ciInput = CIImage(image: image)?.transformed(by: .init(scaleX: minScale, y: minScale))
        filter.setValue(ciInput, forKey: "inputImage")

        guard
            let ciOutput = filter.outputImage,
            let cgImage = context.createCGImage(ciOutput, from: ciOutput.extent)
        else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
}
