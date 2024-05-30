//
//  MainView.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import SwiftUI

struct MainView: View {
	var viewModel = ComicViewModel()
	
	var body: some View {
		VStack {
			if viewModel.isLoading {
				VStack {
					Text("Loading...")
						.font(.headline)
						.padding()
					ProgressView()
						.frame(width: 300, height: 300)
						.padding()
				}
			} else if let comic = viewModel.comics.first {
				Text("Comic number: " + String(comic.num))
					.font(.subheadline)
					.padding()
				Text(comic.title)
					.font(.headline)
					.padding()
				AsyncImage(url: URL(string: comic.img)) { phase in
					switch phase {
						case .empty:
							ProgressView()
								.frame(width: 300, height: 300)
								.padding()
						case .success(let image):
							image
								.resizable()
								.scaledToFit()
								.frame(maxWidth: 300, maxHeight: 300)
						case .failure:
							Image(systemName: "photo")
								.resizable()
								.scaledToFit()
								.frame(maxWidth: 300, maxHeight: 300)
						@unknown default:
							EmptyView()
					}
				}
				.padding()
			} else if let errorMessage = viewModel.errorMessage {
				Text(errorMessage)
					.foregroundColor(.red)
					.padding()
			} else {
				Text("Loading...")
					.padding()
			}
			Button(action: {
				Task {
					await viewModel.fetchRandomComic()
				}
			}) {
				Text("Load Random Comic")
					.padding()
					.background(Color.blue)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			.padding()
		}
		.onAppear {
			Task {
				await viewModel.fetchLatestComic()
			}
		}
	}
}

#Preview {
	MainView( viewModel: ComicViewModel())
		.modelContainer(for: Comic.self, inMemory: true)
}
