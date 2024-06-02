//
//  UserNotifications.swift
//  xkcd comics
//
//  Created by August Elvevold on 02/06/2024.
//

import Foundation
import UserNotifications
import BackgroundTasks
import Observation

@Observable
class NotificationManager {
	
	private let taskID = "private.xkcd-comics.refresh"
	
	func registerBackgroundTasks() {
		print("Registering background tasks")
		BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
			self.handleAppRefresh(task: task as! BGAppRefreshTask)
		}
	}
	
	func askForPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
			if success {
				print("Permission granted")
			} else if let error = error {
				print(error.localizedDescription)
			}
		}
	}
	
	func scheduleNewComicNotification(comic: Comic) {
		// Create the notification content
		let content = UNMutableNotificationContent()
		content.title = "New XKCD Comic Available"
		content.body = "Check out the latest comic titled \"\(comic.title)\""
		content.sound = UNNotificationSound.default
		
		print("Notificate comic: \(comic.num)")
		
		// Create the notification request
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
		
		// Add the request to the notification center
		UNUserNotificationCenter.current().add(request)
	}
	
	func checkForNewComic(apiService: APIService) async {
		do {
			let latestComic = try await apiService.fetchComic(from: APIString.latestComicURL)
			print("Latest comic number: \(latestComic.num)")
			let lastComicNum = UserDefaults.standard.integer(forKey: "lastComicNum")
			print("Last comic number: \(lastComicNum)")
			
			if lastComicNum == 0 || latestComic.num > lastComicNum {
				UserDefaults.standard.set(latestComic.num, forKey: "lastComicNum")
				scheduleNewComicNotification(comic: latestComic)
			}
		} catch {
			print("Failed to fetch comic: \(error.localizedDescription)")
		}
	}
	
	func handleAppRefresh(task: BGAppRefreshTask) {
		print("Handling app refresh")
		scheduleAppRefresh()
		
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		
		let operation = CheckForNewComicOperation(apiService: APIService(), notificationHandler: self)
		task.expirationHandler = {
			queue.cancelAllOperations()
		}
		
		operation.completionBlock = {
			task.setTaskCompleted(success: !operation.isCancelled)
		}
		
		queue.addOperation(operation)
	}
	
	func scheduleAppRefresh() {
		print("Scheduling app refresh")
		let request = BGAppRefreshTaskRequest(identifier: taskID)
		request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now
		do {
			try BGTaskScheduler.shared.submit(request)
			print("Scheduled app refresh")
		} catch {
			print("Could not schedule app refresh: \(error)")
		}
	}
}
