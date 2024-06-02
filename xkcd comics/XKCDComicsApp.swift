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
	private var notificationManager = NotificationManager()
	private let apiService = APIService()
	var comicViewModel = ComicViewModel()
	var body: some Scene {
		WindowGroup {
			ContentView(comicViewModel: ComicViewModel())
				.onAppear {
					notificationManager.askForPermission()
					notificationManager.registerBackgroundTasks()
					notificationManager.scheduleAppRefresh()
				}
		}
		.modelContainer(for: Comic.self)
	}
}
