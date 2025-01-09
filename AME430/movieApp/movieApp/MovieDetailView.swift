//
//  MovieDetailView.swift
//  movieApp
//
//  Created by Bjorn Bradley on 12/9/24.
//

import SwiftUI
import AVKit

struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        VStack(spacing: 16) {
            Text(movie.title)
                .font(.largeTitle)
                .bold()

            Text(movie.description)
                .font(.body)
                .padding(.horizontal)

            if let videoURL = movie.videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
            } else {
                Text("Video not available")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Details")
    }
}

#Preview {
    MovieDetailView(movie: Movie(title: "Sample Movie", description: "Sample Description", videoFileName: "movie1", thumbnailFileName: "movie1_thumbnail"))
}
