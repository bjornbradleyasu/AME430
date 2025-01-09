//
//  extensions.swift
//  imageApp
//
//  Created by Bjorn Bradley on 11/13/24.
//

import AppKit
import CoreImage

extension NSImage {
    var ciImage: CIImage? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
        return CIImage(bitmapImageRep: bitmap)
    }
}
