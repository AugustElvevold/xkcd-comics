//
//  ComicViewModel.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation
import Observation

@Observable
class ComicViewModel{
	var comics: [Comic] = []
	var errorMessage: String?
	var latestComicNumber: Int?
	private var currentComicNumber: Int?
	var latestComic: Bool {
		currentComicNumber == latestComicNumber
	}
	var firstComic: Bool {
		currentComicNumber == 1
	}
	var isLoading: Bool = false
	
	func fetchLatestComic() async {
		isLoading = true
		do {
			let comic = try await fetchComic(from: APIString.latestComicURL)
			DispatchQueue.main.async {
				self.comics = [comic] // Replace the array with the latest comic
				self.latestComicNumber = comic.num
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
			}
		}
	}
	
	func fetchComicByNumber(number: Int) async {
		isLoading = true
		do {
			let comic = try await fetchComic(from: APIString.comicURL(comicNumber: number))
			DispatchQueue.main.async {
				self.comics = [comic] // Replace the array with the comic
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
			}
		}
	}
	
	func fetchRandomComic() async {
		isLoading = true
		do {
			if latestComicNumber == nil {
				await fetchLatestComic() // Ensure latestComicNumber is set
			}
			// Uses latestComicNumber to generate a random comic number that actually exists
			guard let latestComicNumber = latestComicNumber else { return }
			
			let randomComicNumber = Int.random(in: 1...latestComicNumber)
			let comic = try await fetchComic(from: APIString.comicURL(comicNumber: randomComicNumber))
			DispatchQueue.main.async {
				self.comics = [comic] // Replace the array with the random comic
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
			}
		}
	}
	
	func fetchPreviousComic() async {
		isLoading = true
		do {
			if currentComicNumber == nil {
				await fetchLatestComic() // Ensure currentComicNumber is set
			}
			// Uses currentComicNumber to fetch the previous comic
			guard let currentComicNumber = currentComicNumber else { return }
			
			let previousComicNumber = currentComicNumber - 1
			let comic = try await fetchComic(from: APIString.comicURL(comicNumber: previousComicNumber))
			DispatchQueue.main.async {
				self.comics = [comic] // Replace the array with the previous comic
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
			}
		}
	}
	
	func fetchNextComic() async {
		isLoading = true
		do {
			if currentComicNumber == nil {
				await fetchLatestComic() // Ensure currentComicNumber is set
			}
			// Uses currentComicNumber to fetch the next comic
			guard let currentComicNumber = currentComicNumber else { return }
			
			let nextComicNumber = currentComicNumber + 1
			let comic = try await fetchComic(from: APIString.comicURL(comicNumber: nextComicNumber))
			DispatchQueue.main.async {
				self.comics = [comic] // Replace the array with the next comic
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
			}
		}
	}
	
	private func fetchComic(from url: String) async throws -> Comic {
		guard let url = URL(string: url) else {
			throw URLError(.badURL)
		}
		let (data, _) = try await URLSession.shared.data(from: url)
		currentComicNumber = try JSONDecoder().decode(Comic.self, from: data).num
		return try JSONDecoder().decode(Comic.self, from: data)
	}
}
