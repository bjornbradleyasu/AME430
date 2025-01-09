import SwiftUI
import AVKit
import Combine

struct ClipEditView: View {
    @Binding var movie: Movie
    @State private var player: AVPlayer?
    @State private var duration: Double = 0.0 // Cached duration
    @State private var currentTime: Double = 0.0 // Tracks current playback time
    @State private var cancellable: AnyCancellable? // For Combine subscription
    
    var body: some View {
        VStack {
            // Display the poster image
            if let thumbnailURL = movie.thumbnailURL {
                Image(nsImage: NSImage(byReferencing: thumbnailURL))
                    .resizable()
                    .frame(width: 150, height: 100)
                    .cornerRadius(8)
                    .padding()
            }
            
            // Video player preview
            if let videoURL = movie.videoURL {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                    .onAppear {
                        setupPlayer()
                        loadDuration()
                        observeCurrentTime()
                    }
            } else {
                Text("No video available")
                    .font(.headline)
            }
            
            // Display current playback time
            Text("Current Time: \(formattedTime(currentTime))")
                .font(.subheadline)
                .padding()
            
            // inTime slider
            HStack {
                Text("In Time: \(formattedTime(movie.inTime))")
                Slider(value: Binding(
                    get: { movie.inTime },
                    set: { newValue in
                        movie.inTime = newValue
                        if movie.inTime >= movie.outTime {
                            movie.inTime = movie.outTime - 0.1 // Prevent overlap
                        }
                        seekToInTime()
                    }
                ), in: 0...max(0, movie.outTime - 0.1)) // Ensure inTime range is valid
            }
            .padding()
            
            // outTime slider
            HStack {
                Text("Out Time: \(formattedTime(movie.outTime))")
                Slider(value: Binding(
                    get: { movie.outTime },
                    set: { newValue in
                        movie.outTime = newValue
                        if movie.outTime <= movie.inTime {
                            movie.outTime = movie.inTime + 0.1 // Prevent overlap
                        }
                        applyOutTimeConstraint()
                    }
                ), in: min(movie.inTime + 0.1, duration)...duration) // Ensure outTime range is valid
            }
            .padding()
            
            // Playback control buttons
            HStack {
                Button("First Frame") {
                    player?.seek(to: .zero)
                }
                Button("In Time") {
                    player?.seek(to: CMTime(seconds: movie.inTime, preferredTimescale: 600))
                }
                Button("Out Time") {
                    player?.seek(to: CMTime(seconds: movie.outTime, preferredTimescale: 600))
                }
                Button("Last Frame") {
                    player?.seek(to: CMTime(seconds: duration, preferredTimescale: 600))
                }
                Button("Set Poster Image") {
                    setPosterImage()
                }
            }
            .padding()
            
            HStack {
                Button("Play Backward") {
                    player?.rate = -1.0 // Play backward
                }
                Button("Pause") {
                    player?.pause()
                }
                Button("Play Forward") {
                    player?.rate = 1.0 // Play forward
                }
            }
            .padding()
        }
        .padding()
        .onDisappear {
            cancellable?.cancel()
        }
    }
    
    // MARK: - Player Setup
    
    private func setupPlayer() {
        guard let videoURL = movie.videoURL else { return }
        
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Apply inTime and outTime constraints
        playerItem.forwardPlaybackEndTime = CMTime(seconds: movie.outTime, preferredTimescale: 600)
        player = AVPlayer(playerItem: playerItem)
        player?.seek(to: CMTime(seconds: movie.inTime, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func loadDuration() {
        guard let url = movie.videoURL else { return }
        let asset = AVURLAsset(url: url)
        
        Task {
            do {
                let loadedDuration = try await asset.load(.duration).seconds
                DispatchQueue.main.async {
                    self.duration = loadedDuration
                }
            } catch {
                print("Failed to load duration: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.duration = 0.0
                }
            }
        }
    }
    
    private func observeCurrentTime() {
        cancellable = player?.periodicTimeObserverPublisher(interval: CMTime(seconds: 1, preferredTimescale: 600))
            .sink { time in
                currentTime = time.seconds
            }
    }
    
    // MARK: - Poster Image and Playback Adjustments
    
    private func setPosterImage() {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let asset = AVURLAsset(url: movie.videoURL!)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: currentTime, actualTime: nil)
            let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: 100, height: 150))
            movie.thumbnailFileName = saveThumbnail(nsImage)
        } catch {
            print("Failed to generate poster image: \(error.localizedDescription)")
        }
    }
    
    private func saveThumbnail(_ image: NSImage) -> String {
        let fileName = UUID().uuidString + ".png"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            do {
                try pngData.write(to: fileURL)
                return fileName
            } catch {
                print("Failed to save thumbnail: \(error.localizedDescription)")
            }
        }
        return ""
    }
    
    private func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func seekToInTime() {
        player?.seek(to: CMTime(seconds: movie.inTime, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func applyOutTimeConstraint() {
        player?.currentItem?.forwardPlaybackEndTime = CMTime(seconds: movie.outTime, preferredTimescale: 600)
    }
    private func playForward() {
        player?.pause()
        player?.rate = 1.0 // Ensure positive playback rate
        player?.play()
    }

    private func playBackward() {
        player?.pause()
        player?.rate = -1.0 // Set negative rate for reverse playback
        player?.play()
    }
}
