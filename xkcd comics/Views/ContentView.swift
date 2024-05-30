//
//  ContentView.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	var comicViewModel: ComicViewModel
	var searchService: XKCDSearchService
	
	var body: some View {
		TabView {
			MainView(
				comicViewModel: comicViewModel,
				searchService: searchService
			)
				.tabItem {
					Label("Browse comics", systemImage: "house")
				}
			SavedView()
				.tabItem {
					Label("Saved comics", systemImage: "list.bullet")
				}
		}
	}
}

#Preview {
	ContentView(
		comicViewModel: ComicViewModel(),
		searchService: XKCDSearchService()
	)
		.modelContainer(for: Comic.self)
}
