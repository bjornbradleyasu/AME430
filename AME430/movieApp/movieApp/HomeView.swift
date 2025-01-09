//
//  HomeView.swift
//  movieApp
//

import SwiftUI
import AVKit
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var movies: [Movie] = [] // Start with an empty playlist
    @State private var draggedMovie: Movie? = nil // Track the movie being dragged
    @State private var selectedMovie: Movie? = nil // Tracks the selected movie
    @State private var showMainPlayback = false // Tracks whether the MainPlaybackView should be shown
    
    var body: some View {
        NavigationView {
            // Left Pane: Editable Movie List
            VStack {
                Text("Movie Playlist")
                    .font(.headline)
                    .padding()

                List {
                    ForEach(movies) { movie in
                        HStack {
                            if let thumbnailURL = movie.thumbnailURL {
                                Image(nsImage: NSImage(byReferencing: thumbnailURL))
                                    .resizable()
                                    .frame(width: 200, height: 150) // Increased size
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(8)
                            }

                            VStack(alignment: .leading) {
                                Text(movie.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text("Duration: \(formattedDuration(for: movie))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Button(action: {
                                removeMovie(movie)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMovie = movie // Set the selected movie for playback
                            showMainPlayback = false // Disable main playback for individual playback
                        }

                        // NavigationLink for editing
                        NavigationLink(
                            destination: ClipEditView(movie: Binding(
                                get: { movie },
                                set: { updatedMovie in
                                    if let index = movies.firstIndex(where: { $0.id == movie.id }) {
                                        movies[index] = updatedMovie
                                    }
                                }
                            )),
                            label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        )
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    importMovie()
                }) {
                    Text("Import Movie")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .buttonStyle(BorderedButtonStyle())
            }
            .frame(minWidth: 300) // Adjusts the minimum width for better layout

            // Right Pane: Playback (either individual clip or all clips)
            VStack {
                if showMainPlayback {
                    MainPlaybackView(movies: movies)
                } else if let selectedMovie = selectedMovie, let videoURL = selectedMovie.videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Select a movie to play")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Play all Clips") {
                    selectedMovie = nil // Clear the selected movie
                    showMainPlayback = true // Switch to MainPlaybackView
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("Save Playlist") {
                    savePlaylist()
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("Load Playlist") {
                    loadPlaylist()
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("Export Playlist") {
                    exportPlaylist()
                }
            }
        }
        .navigationTitle("Movies")
        .navigationViewStyle(DoubleColumnNavigationViewStyle()) // Ensures macOS layout
    }
    
    private func formattedDuration(for movie: Movie) -> String {
            guard let videoURL = movie.videoURL else { return "Unknown" }
            let asset = AVURLAsset(url: videoURL)
            let duration = asset.duration.seconds
            return String(format: "%02d:%02d", Int(duration) / 60, Int(duration) % 60)
        }
    
    // MARK: - Functions
    
    /// Imports a new movie from disk and adds it to the playlist, generating a thumbnail from the first frame
    private func importMovie() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .mpeg4Movie]
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            generateThumbnail(from: url) { thumbnailFileName in
                let newMovie = Movie(
                    title: url.lastPathComponent,
                    description: "",
                    videoFileName: url.path,
                    thumbnailFileName: thumbnailFileName ?? "placeholder_thumbnail"
                )
                DispatchQueue.main.async {
                    movies.append(newMovie) // Update the movies list on the main thread
                }
            }
        }
    }
    
    /// Generates a thumbnail image asynchronously from the first frame of a video
    private func generateThumbnail(from url: URL, completion: @escaping (String?) -> Void) {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600) // First frame at 0 seconds
        let thumbnailFileName = UUID().uuidString + ".png"
        let thumbnailURL = FileManager.default.temporaryDirectory.appendingPathComponent(thumbnailFileName)
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, _, error in
            if let cgImage = cgImage {
                let thumbnailImage = NSImage(cgImage: cgImage, size: NSSize(width: 100, height: 150))
                
                if let tiffData = thumbnailImage.tiffRepresentation,
                   let bitmapRep = NSBitmapImageRep(data: tiffData),
                   let pngData = bitmapRep.representation(using: .png, properties: [:]) {
                    do {
                        try pngData.write(to: thumbnailURL)
                        DispatchQueue.main.async {
                            completion(thumbnailFileName) // Return the thumbnail file name
                        }
                        return
                    } catch {
                        print("Error saving thumbnail: \(error.localizedDescription)")
                    }
                }
            } else if let error = error {
                print("Error generating thumbnail: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(nil) // Return nil in case of failure
            }
        }
    }
    
    /// Removes a movie from the playlist
    private func removeMovie(_ movie: Movie) {
        movies.removeAll { $0.id == movie.id }
    }
    
    /// Moves a movie within the playlist
    private func moveMovie(from sourceIndex: Int) {
        guard let draggedMovie = draggedMovie else { return }
        movies.remove(at: sourceIndex)
        if let targetIndex = movies.firstIndex(of: selectedMovie ?? draggedMovie) {
            movies.insert(draggedMovie, at: targetIndex)
        } else {
            movies.append(draggedMovie)
        }
    }
    
    /// Saves the current movie playlist to a .plist file
    private func savePlaylist() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.propertyList]
        panel.nameFieldStringValue = "MoviePlaylist"
        
        if panel.runModal() == .OK, let url = panel.url {
            DispatchQueue.global(qos: .background).async {
                do {
                    let encoder = PropertyListEncoder()
                    let data = try encoder.encode(movies)
                    try data.write(to: url)
                    DispatchQueue.main.async {
                        print("Playlist saved to \(url.path)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Failed to save playlist: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func loadPlaylist() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.propertyList]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK, let url = panel.url {
            DispatchQueue.global(qos: .background).async {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = PropertyListDecoder()
                    let loadedMovies = try decoder.decode([Movie].self, from: data)
                    DispatchQueue.main.async {
                        movies = loadedMovies
                        print("Playlist loaded from \(url.path)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Failed to load playlist: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    /// Exports the current movie playlist as a single movie file
    private func exportPlaylist() {
        guard !movies.isEmpty else {
            print("No movies in the playlist to export.")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.movie]
        savePanel.nameFieldStringValue = "ExportedPlaylist"
        
        if savePanel.runModal() == .OK, let outputURL = savePanel.url {
            Task {
                do {
                    // Create the composition
                    let composition = AVMutableComposition()
                    
                    // Add a video track to the composition
                    guard let videoTrack = composition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID: kCMPersistentTrackID_Invalid
                    ) else {
                        print("Failed to create video track.")
                        return
                    }
                    
                    var currentTime = CMTime.zero
                    
                    // Add each movie clip to the composition
                    for movie in movies {
                        guard let movieURL = movie.videoURL else {
                            print("Invalid movie URL for \(movie.title). Skipping...")
                            continue
                        }
                        
                        let asset = AVURLAsset(url: movieURL)
                        let duration = try await asset.load(.duration)
                        let videoTracks = try await asset.loadTracks(withMediaType: .video)
                        
                        guard let assetTrack = videoTracks.first else {
                            print("No video track found in \(movie.title).")
                            continue
                        }
                        
                        let timeRange = CMTimeRange(start: .zero, duration: duration)
                        try videoTrack.insertTimeRange(timeRange, of: assetTrack, at: currentTime)
                        
                        currentTime = currentTime + duration
                    }
                    
                    // Create an export session for the composition
                    guard let exportSession = AVAssetExportSession(
                        asset: composition,
                        presetName: AVAssetExportPresetHighestQuality
                    ) else {
                        print("Failed to create export session.")
                        return
                    }
                    
                    exportSession.outputURL = outputURL
                    exportSession.outputFileType = .mov
                    
                    // Export the composition
                    try await exportSession.export(to: outputURL, as: .mov)
                    print("Playlist successfully exported to \(outputURL.path).")
                } catch {
                    print("Failed to export playlist: \(error.localizedDescription)")
                }
            }
        }
    }
}
