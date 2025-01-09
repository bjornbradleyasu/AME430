import SwiftUI
import AVKit

struct SeamlessVideoPlayer: NSViewRepresentable {
    let movieFiles: [String] // Array of file paths for video clips

    func makeNSView(context: Context) -> AVPlayerView {
        let player = AVQueuePlayer()

        // Add all video clips to the player queue
        for filePath in movieFiles {
            let fileURL = URL(fileURLWithPath: filePath)
            let playerItem = AVPlayerItem(url: fileURL)
            player.insert(playerItem, after: nil)
        }

        // Enable looping
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        let playerView = AVPlayerView()
        playerView.player = player
        player.play()
        return playerView
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {}

    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: ()) {
        nsView.player?.pause()
        nsView.player = nil
    }
}
