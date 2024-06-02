//
//  SearchView.swift
//  xkcd comics
//
//  Created by August Elvevold on 02/06/2024.
//

import SwiftUI

struct SearchView: View {
	@Environment(\.modelContext) private var modelContext
	@Bindable var comicViewModel: ComicViewModel
	@State var searchTerm = ""
	@State private var isSheetPresented = false
	@State private var selectedComic: Comic?
	
    var body: some View {
			NavigationStack{
				VStack {
					if !comicViewModel.searchResultComics.isEmpty {
						ScrollView {
							LazyVStack {
								ForEach(comicViewModel.searchResultComics) { comic in
									ComicView(comic: comic,
														saveAction: { saveComic(comic: comic) },
														showExplanationAction: { showExplanation(comic: comic) },
														comicViewModel: comicViewModel,
														selectedComic: $selectedComic
									)
									.padding()
									.background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
								}
							}
						}
						Spacer()
					} else {
						ContentUnavailableView("Search for comics by text or thier number", systemImage: "magnifyingglass")
					}
				}
				.navigationTitle("search xkcd comics")
				.searchable(text: $searchTerm, prompt: "Search for comics")
				.onSubmit(of: .search) {
					if let number = Int(searchTerm),
						 number >= 1,
						 number <= comicViewModel.newestComicNumber ?? 1000 {
						Task {
							await comicViewModel.fetchComicByNumber(number: number)
						}
					} else {
						Task {
							await comicViewModel.fetchComicBySearch(query: searchTerm)
						}
					}
				}
				.sheet(isPresented: $isSheetPresented) {
					if let comic = selectedComic {
						SheetView(comic: comic)
							.presentationDetents([.height(250), .large])
					}
				}
			}
    }
	func saveComic(comic: Comic) {
		modelContext.insert(comic)
		try? modelContext.save()
	}
	
	func showExplanation(comic: Comic) {
		Task {
			await comicViewModel.fetchExplanation(for: comic.num, comicTitle: comic.title)
			isSheetPresented = true
		}
	}
}

#Preview {
    SearchView(comicViewModel: ComicViewModel())
				.modelContainer(for: Comic.self)
}
