import Foundation
import AVFoundation

struct Movie: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let videoFileName: String
    var thumbnailFileName: String?
    var inTime: Double
    var outTime: Double

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        videoFileName: String,
        thumbnailFileName: String? = nil,
        inTime: Double = 0.0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.videoFileName = videoFileName
        self.thumbnailFileName = thumbnailFileName
        self.inTime = inTime

        // Calculate video duration
        if let duration = Movie.getVideoDuration(url: URL(fileURLWithPath: videoFileName)) {
            self.outTime = duration
        } else {
            self.outTime = 0.0 // Fallback in case duration cannot be fetched
        }
    }

    var videoURL: URL? {
        URL(fileURLWithPath: videoFileName)
    }

    var thumbnailURL: URL? {
        guard let thumbnailFileName = thumbnailFileName else { return nil }
        let tempDirectory = FileManager.default.temporaryDirectory
        return tempDirectory.appendingPathComponent(thumbnailFileName)
    }

    static func getVideoDuration(url: URL) -> Double? {
        let asset = AVURLAsset(url: url)
        return asset.duration.seconds.isFinite ? asset.duration.seconds : nil
    }
}
