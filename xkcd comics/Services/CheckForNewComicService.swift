//
//  CheckForNewComicService.swift
//  xkcd comics
//
//  Created by August Elvevold on 02/06/2024.
//

import Foundation

class CheckForNewComicOperation: Operation {
	private let apiService: APIService
	private let notificationHandler: NotificationManager
	
	init(apiService: APIService, notificationHandler: NotificationManager) {
		self.apiService = apiService
		self.notificationHandler = notificationHandler
	}
	
	override func main() {
		Task {
			await notificationHandler.checkForNewComic(apiService: apiService)
		}
	}
}
