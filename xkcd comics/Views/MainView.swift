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
	var searchService: XKCDSearchService
	@State var searchTerm = ""
	@State private var isSheetPresented = false
	
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
					HStack{
						Text("Comic number: " + String(comic.num))
							.font(.caption)
						Spacer()
						Text(comicViewModel.formatNorwegianDate(comic.day, comic.month, comic.year) ?? "")
							.font(.caption)
					}
					.padding(.horizontal)
					Text(comic.alt)
						.font(.subheadline)
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
				HStack{
					Spacer()
					VStack(alignment: .trailing, spacing: 20) {
						Button() {
							saveComic(comic: comicViewModel.comics.first!)
						} label: {
							Label("Lagre", systemImage: "tray.and.arrow.down.fill")
						}
						.tint(.blue)
						Button() {
							isSheetPresented = true
							comicViewModel.fetchExplanation(for: comicViewModel.comics.first!.num, comicTitle: comicViewModel.comics.first!.title)
						} label: {
							Label("See explanation", systemImage: "questionmark.circle")
						}
					}
				}
				.padding(.horizontal)
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
				if let number = searchService.searchFirstComicID(query: searchTerm) {
					Task {
						await comicViewModel.fetchComicByNumber(number: number)
					}
				}
			}
		}
		.sheet(isPresented: $isSheetPresented) {
			SheetView(comic: comicViewModel.comics.first!)
				.presentationDetents([.height(250), .large])
		}
	}
	
	func saveComic(comic: Comic) {
		modelContext.insert(comic)
		try? modelContext.save()
	}
}

struct SheetView: View {
	@Environment(\.modelContext) private var modelContext
	var comic: Comic
	
	var body: some View {
		ScrollView {
			if comic.explanation == "" {
				ProgressView("Loading...")
			} else {
				Text(comic.title + " explanation")
					.font(.headline)
					.padding(.top, 20)
				Text(comic.explanation ?? "No explanation found")
					.padding()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.white)
	}
}

#Preview {
	MainView(
		comicViewModel: ComicViewModel(),
		searchService: XKCDSearchService()
	)
	.modelContainer(for: Comic.self, inMemory: true)
}
