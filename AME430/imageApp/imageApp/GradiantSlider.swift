//
//  GradiantSlider.swift
//  imageApp
//
//  Created by Bjorn Bradley on 11/13/24.
//

import SwiftUI

struct GradientSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Gradient background for the slider track
                LinearGradient(
                    gradient: Gradient(colors: [.red, .yellow, .green, .cyan, .blue, .purple, .red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 8)
                .cornerRadius(4)
                
                // Thumb indicator
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.gray)
                    .offset(x: thumbOffset(geometry: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(gesture.location.x / geometry.size.width)
                                self.value = min(max(newValue, range.lowerBound), range.upperBound)
                            }
                    )
            }
        }
        .frame(height: 16)
    }
    
    // Calculate thumb position based on value
    private func thumbOffset(geometry: GeometryProxy) -> CGFloat {
        let percentage = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(percentage) * geometry.size.width - 8 // Offset by half the thumb width
    }
}
