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
			MainView()
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
		comicViewModel: ComicViewModel()
	)
		.modelContainer(for: Comic.self, inMemory: true)
}
