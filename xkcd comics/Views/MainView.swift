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
	@State private var isSheetPresented = false
	@State private var selectedComic: Comic?
	
	var body: some View {
		NavigationStack{
			VStack {
				Picker("Filter", selection: $comicViewModel.selectedFilter) {
					ForEach(FilterType.allCases, id: \.self) {
						Text($0.rawValue)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding(.horizontal)
				.onChange(of: comicViewModel.selectedFilter) { comicViewModel.handleFilterChange() }
				
				ScrollView {
					LazyVStack {
						ForEach(comicViewModel.currentComics) { comic in
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
			}
			.navigationTitle("xkcd comics")
			.onAppear {
				if comicViewModel.newestComics.isEmpty {
					Task {
						await comicViewModel.fetchNewestComic()
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
	MainView(comicViewModel: ComicViewModel())
		.modelContainer(for: Comic.self, inMemory: true)
}
