//
//  ImageProcessor.swift
//  imageApp
//
//  Created by Bjorn Bradley on 11/13/24.
//

import AppKit
import CoreImage

class ImageProcessor {
    private let context = CIContext()
    
    // Hue shift filter
    func applyHueFilter(to image: NSImage, hueAngle: Double) -> NSImage? {
        guard let ciImage = CIImage(data: image.tiffRepresentation!) else { return nil }
        
        let hueFilter = CIFilter(name: "CIHueAdjust")
        hueFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        hueFilter?.setValue(hueAngle, forKey: kCIInputAngleKey) // Hue angle in radians
        
        guard let outputImage = hueFilter?.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return NSImage(cgImage: cgImage, size: NSSize(width: outputImage.extent.width, height: outputImage.extent.height))
    }
    
    // Monochrome filter with adjustable intensity
    func applyMonochromeFilter(to image: NSImage, intensity: Double) -> NSImage? {
        guard let ciImage = CIImage(data: image.tiffRepresentation!) else { return nil }
        
        let colorFilter = CIFilter(name: "CIColorMonochrome")
        colorFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        colorFilter?.setValue(CIColor(color: .blue), forKey: kCIInputColorKey) // You can use different colors here
        colorFilter?.setValue(intensity, forKey: kCIInputIntensityKey) // Adjustable intensity
        
        guard let outputImage = colorFilter?.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return NSImage(cgImage: cgImage, size: NSSize(width: outputImage.extent.width, height: outputImage.extent.height))
    }
}



