//
//  ContentViewModel.swift
//  imageApp
//
//  Created by Bjorn Bradley on 11/13/24.
//

import SwiftUI
import CoreImage
import Vision

class ContentViewModel: ObservableObject {
    @Published var originalImage: NSImage?
    @Published var processedImage: NSImage?
    
    private let imageProcessor = ImageProcessor()
    
    func loadImage(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let imageData = try Data(contentsOf: url)
                if let nsImage = NSImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.originalImage = nsImage
                        self.processedImage = nil // Reset processed image when a new image is loaded
                    }
                } else {
                    print("Failed to create NSImage from data.")
                }
            } catch {
                print("Error loading image data: \(error)")
            }
        case .failure(let error):
            print("Error loading image: \(error)")
        }
    }
    
    func applyCombinedFilters(hueAngle: Double, monochromeIntensity: Double) {
        guard let originalImage = originalImage else { return }
        
        var processedImage = imageProcessor.applyHueFilter(to: originalImage, hueAngle: hueAngle)
        if monochromeIntensity > 0 {
            processedImage = imageProcessor.applyMonochromeFilter(to: processedImage ?? originalImage, intensity: monochromeIntensity)
        }
        
        self.processedImage = processedImage
    }
}
