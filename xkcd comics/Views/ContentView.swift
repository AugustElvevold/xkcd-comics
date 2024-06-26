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
	
	var body: some View {
		TabView {
			MainView(comicViewModel: comicViewModel)
				.tabItem {
					Label("Browse comics", systemImage: "house")
				}
			SearchView(comicViewModel: comicViewModel)
				.tabItem {
					Label("Search comics", systemImage: "magnifyingglass")
				}
			SavedView()
				.tabItem {
					Label("Saved comics", systemImage: "list.bullet")
				}
		}
	}
}

#Preview {
	ContentView(comicViewModel: ComicViewModel())
		.modelContainer(for: Comic.self)
}
