//
//  ContentView.swift
//  Json Assignment
//
//  Created by Bjorn Bradley on 10/17/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LyricsViewModel()
    @StateObject private var recommendationViewModel = RecommendationViewModel()
    @StateObject private var favoriteManager = FavoriteManager()
    @State private var searchText = ""
    
    let backgroundColor = Color(red: 1/255, green: 22/255, blue: 39/255) // #011627
        let leftPaneColor = Color(red: 86/255, green: 63/255, blue: 27/255) // #563F1B
        let textColor = Color(red: 198/255, green: 161/255, blue: 91/255) // #C6A15B
        let secondaryColor = Color(red: 229/255, green: 234/255, blue: 250/255) // #E5EAFA
        let dividerColor = Color(red: 75/255, green: 78/255, blue: 109/255) // #4B4E6D
        let favoriteColor = Color(red: 181/255, green: 173/255, blue: 16/255) //#b5ad10
    
    @State private var isLoading = false
    @State private var isFavorite = false
    
    var body: some View {
        HStack {
            // Left Pane: Search & Recommendations
            VStack {
                // Search bar
                TextField("Search for a song: Song - Artist", text: $searchText, onCommit: {
                    viewModel.fetchLyrics(searchTerm: searchText)
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { newValue in
                    recommendationViewModel.fetchRecommendations(searchTerm: newValue)
                }
                .padding(.bottom, 10)
                .foregroundColor(textColor)
                
                // List of recommendations
                if !recommendationViewModel.recommendations.isEmpty {
                    List(recommendationViewModel.recommendations) { recommendation in
                        Text(recommendation.title)
                            .padding()
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    searchText = recommendation.title
                                    viewModel.fetchLyrics(searchTerm: recommendation.title)
                                    isFavorite = favoriteManager.isFavorite(songTitle: recommendation.title)
                                }
                            }
                            .foregroundColor(textColor)
                            .scaleEffect(1.1)
                            .animation(.spring(response: 0.3, dampingFraction:0.5))
                    }
                } else {
                    Text("No recommendations yet")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .frame(maxWidth: 300)
            .padding()
            
            Divider() // Separator between panes
                .background(dividerColor)
            
            // Right Pane: Lyrics Display
            VStack {
                if let lyrics = viewModel.lyrics {
                    ScrollView {
                        Text(lyrics)
                            .padding()
                            .foregroundColor(textColor)
                            .font(.system(size: 26, weight: .bold))
                            .lineSpacing(10)
                            .multilineTextAlignment(.leading)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.5), value: viewModel.lyrics)
                    }
                    Button(action: {
                        favoriteManager.toggleFavorite(songTitle: searchText)
                        isFavorite = favoriteManager.isFavorite(songTitle: searchText)
                    }) {
                        Image(systemName: "star.fill")
                            .foregroundColor(isFavorite ? favoriteColor : .clear)
                            .background(
                                Image(systemName: "star")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                            )
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding([.leading, .bottom])
                } else if viewModel.isLoading {
                    ProgressView("Fetching lyrics...")
                        .foregroundColor(secondaryColor)
                        .scaleEffect(isLoading ? 1.2 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isLoading)
                        .onAppear {
                            isLoading = true
                        }
                        .onDisappear() {
                            isLoading = false
                        }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("No lyrics available")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            
            Divider()
            
            VStack {
                Text("Favorites")
                    .font(.headline)
                    .foregroundColor(textColor)
                    .padding()
                
                if favoriteManager.favoritedSongs.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(Array(favoriteManager.favoritedSongs), id: \.self) { song in
                        Text(song.title)
                            .padding()
                            .foregroundColor(textColor)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    searchText = song.title
                                    viewModel.fetchLyrics(searchTerm: song.title)
                                    isFavorite = true
                                }
                            }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: 300)
            .background(leftPaneColor)
            .padding()
        }
            .navigationTitle("Karaoke Lyrics")
            .background(backgroundColor)
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
