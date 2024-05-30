//
//  MainView.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import SwiftUI
import SwiftData

struct MainView: View {
	@Environment(\.modelContext) private var modelContext
	@Bindable var comicViewModel: ComicViewModel
	@State var searchTerm = ""
	
	var body: some View {
		NavigationStack{
			VStack {
				if comicViewModel.isLoading {
					VStack {
						Text("Loading...")
							.font(.headline)
							.padding()
						ProgressView()
							.frame(width: 300, height: 300)
							.padding()
					}
				} else if let comic = comicViewModel.comics.first {
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
				} else if let errorMessage = comicViewModel.errorMessage {
					Text(errorMessage)
						.foregroundColor(.red)
						.padding()
				} else {
					Text("Loading...")
						.padding()
				}
				Spacer()
				VStack(alignment: .trailing, spacing: 20) {
					Button() {
						saveComic(comic: comicViewModel.comics.first!)
					} label: {
						Label("Lagre", systemImage: "tray.and.arrow.down.fill")
					}
					.tint(.blue)
				}
				HStack{
					Button(action: {
						Task {
							await comicViewModel.fetchPreviousComic()
						}
					}) {
						Text("Previous")
							.padding()
							.background(comicViewModel.firstComic ? Color.gray : Color.blue)
							.foregroundColor(.white)
							.cornerRadius(8)
					}
					.disabled(comicViewModel.firstComic)
					Button(action: {
						Task {
							await comicViewModel.fetchRandomComic()
						}
					}) {
						Text("Random")
							.padding()
							.background(Color.blue)
							.foregroundColor(.white)
							.cornerRadius(8)
					}
					Button(action: {
						Task {
							await comicViewModel.fetchNextComic()
						}
					}) {
						Text("Next")
							.padding()
							.background(comicViewModel.latestComic ? Color.gray : Color.blue)
							.foregroundColor(.white)
							.cornerRadius(8)
					}
					.disabled(comicViewModel.latestComic)
				}
				.padding()
			}
		}
		.navigationTitle("xkcd comics")
		.onAppear {
			if comicViewModel.comics.isEmpty {
				Task {
					await comicViewModel.fetchLatestComic()
				}
			}
		}
		.searchable(text: $searchTerm, prompt: "Search for comic number")
		.onSubmit(of: .search) {
			if let number = Int(searchTerm),
				 number >= 1,
				 number <= comicViewModel.latestComicNumber ?? 1000 {
				Task {
					await comicViewModel.fetchComicByNumber(number: number)
				}
			} else {
				// Handle invalid input if needed
				print("Invalid comic number")
			}
		}
	}
	
	func saveComic(comic: Comic) {
		modelContext.insert(comic)
		try? modelContext.save()
	}
}

#Preview {
	MainView( comicViewModel: ComicViewModel())
		.modelContainer(for: Comic.self, inMemory: true)
}
