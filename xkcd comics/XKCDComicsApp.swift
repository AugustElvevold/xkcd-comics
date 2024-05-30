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
	var body: some Scene {
		WindowGroup {
			ContentView(comicViewModel: ComicViewModel())
		}
		.modelContainer(for: Comic.self)
	}
}
