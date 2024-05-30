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
			if let comic = viewModel.comics.first {
				Text(comic.title)
					.font(.headline)
					.padding()
				AsyncImage(url: URL(string: comic.img)) { phase in
					switch phase {
						case .empty:
							ProgressView()
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
		}
		.onAppear {
			Task {
				do {
					try await viewModel.fetchLatestComic()
				} catch {
					viewModel.errorMessage = error.localizedDescription
				}
			}
		}
	}
}

#Preview {
	MainView( viewModel: ComicViewModel())
		.modelContainer(for: Comic.self, inMemory: true)
}
