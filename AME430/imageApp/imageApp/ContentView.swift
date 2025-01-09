//
//  ContentView.swift
//  imageApp
//
//  Created by Bjorn Bradley on 11/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showImagePicker = false
    @State private var hueAngle: Double = 0.0 // Angle in radians for hue shift
    @State private var monochromeIntensity: Double = 0.5 // Intensity for monochrome filter

    var body: some View {
        VStack {
            HStack {
                // Original Image
                if let image = viewModel.originalImage {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .padding()
                }
                
                // Processed Image
                if let processedImage = viewModel.processedImage {
                    ProcessedImageView(image: processedImage)
                }
            }
            
            VStack {
                // Hue Adjustment Slider with Gradient
                Text("Adjust Hue")
                GradientSlider(value: $hueAngle, range: 0...(2 * .pi))
                    .frame(height: 20) // Adjust frame height as needed
                    .padding(.horizontal)
                    .onChange(of: hueAngle) { newValue in
                        viewModel.applyCombinedFilters(hueAngle: hueAngle, monochromeIntensity: monochromeIntensity)
                    }
                
                // Monochrome Intensity Slider
                Text("Adjust Monochrome Intensity")
                Slider(value: $monochromeIntensity, in: 0...1) {
                    
                }
                .padding(.horizontal)
                .accentColor(.gray)
                .onChange(of: monochromeIntensity) { newValue in
                    viewModel.applyCombinedFilters(hueAngle: hueAngle, monochromeIntensity: monochromeIntensity)
                }
            }
            
            HStack {
                Button("Select Image") {
                    showImagePicker = true
                }
                
                Button("Apply Filters") {
                    viewModel.applyCombinedFilters(hueAngle: hueAngle, monochromeIntensity: monochromeIntensity)
                }
                .disabled(viewModel.originalImage == nil)
            }
        }
        .padding()
        .fileImporter(isPresented: $showImagePicker, allowedContentTypes: [.image], onCompletion: viewModel.loadImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
