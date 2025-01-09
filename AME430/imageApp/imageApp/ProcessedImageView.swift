//
//  ProcessedImageView.swift
//  imageApp
//
//  Created by Bjorn Bradley on 11/13/24.
//

import SwiftUI

struct ProcessedImageView: View {
    var image: NSImage
    
    var body: some View {
        Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 300, maxHeight: 300)
            .padding()
    }
}

struct ProcessedImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessedImageView(image: NSImage())
    }
}
