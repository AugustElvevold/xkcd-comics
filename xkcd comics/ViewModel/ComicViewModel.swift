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
	
	func fetchLatestComic() async throws {
		guard let url = URL(string: APIString.latestComicURL) else {
			throw URLError(.badURL)
		}
		let (data, _) = try await URLSession.shared.data(from: url)
		let decoded = try JSONDecoder().decode(Comic.self, from: data)
		comics.append(decoded)
	}
}
