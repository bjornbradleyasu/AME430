//
//  MainPlaybackView.swift
//  movieApp
//

import SwiftUI
import AVKit

struct MainPlaybackView: View {
    let movies: [Movie]
    @State private var player: AVQueuePlayer? = nil

    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        setupPlayer()
                        player.play()
                    }
            } else {
                Text("No movies to play.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private func setupPlayer() {
        guard !movies.isEmpty else {
            print("No movies in the playlist.")
            return
        }

        let queuePlayer = AVQueuePlayer()

        for movie in movies {
            if let url = movie.videoURL {
                let asset = AVURLAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)

                // Apply inTime and outTime constraints
                let startTime = CMTime(seconds: movie.inTime, preferredTimescale: 600)
                let endTime = CMTime(seconds: movie.outTime, preferredTimescale: 600)
                playerItem.forwardPlaybackEndTime = endTime

                // Debugging: Check if start and end times are valid
                if startTime >= endTime {
                    print("Invalid time range for movie: \(movie.title)")
                    continue
                }

                queuePlayer.insert(playerItem, after: nil)
            } else {
                print("Invalid video URL for movie: \(movie.title)")
            }
        }

        if queuePlayer.items().isEmpty {
            print("No valid clips were added to the player.")
            return
        }

        player = queuePlayer
        print("Player initialized with \(queuePlayer.items().count) items.")
    }
}
