//
//  xkcd_comicsApp.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import SwiftUI
import SwiftData

@main
struct XKCDComicsApp: App {
	var comicViewModel = ComicViewModel()
	let searchService = XKCDSearchService()
	var body: some Scene {
		WindowGroup {
			ContentView(comicViewModel: ComicViewModel(), searchService: searchService)
		}
		.modelContainer(for: Comic.self)
	}
}
