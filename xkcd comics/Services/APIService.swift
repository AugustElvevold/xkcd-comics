//
//  APIService.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation
import SwiftData

struct APIString {
	// Base URL for the XKCD API
	static let baseURL = "https://xkcd.com/"
	static let endURL = "/info.0.json"
	
	// Base URL for the Typesense search API
	static let searchBaseURL = "https://qtg5aekc2iosjh93p.a1.typesense.net/multi_search?use_cache=true&x-typesense-api-key="
	static let searchAPIKey = "8hLCPSQTYcBuK29zY5q6Xhin7ONxHy99"
	
	// Returns the URL for the latest comic
	static var latestComicURL: String {
		return "\(baseURL)info.0.json"
	}
	
	// Returns the URL for a specific comic number
	static func comicURL(comicNumber: Int) -> String {
		return "\(baseURL)\(comicNumber)\(endURL)"
	}
	
	// Returns the URL for the explanation of a specific comic
	static func explanationURL(comicNumber: Int, comicTitle: String) -> String {
		let comicTitleFormatted = comicTitle.replacingOccurrences(of: " ", with: "_")
		return "https://www.explainxkcd.com/wiki/api.php?action=parse&page=\(comicNumber):_\(comicTitleFormatted)&prop=wikitext&sectiontitle=Explanation&format=json"
	}
	
	// Returns the URL for the Typesense search API
	static var searchURL: String {
		return "\(searchBaseURL)\(searchAPIKey)"
	}
}

class APIService {
	
	// Fetches a comic from a given URL
	func fetchComic(from url: String) async throws -> Comic {
		guard let url = URL(string: url) else {
			throw URLError(.badURL)
		}
		let (data, _) = try await URLSession.shared.data(from: url)
		return try JSONDecoder().decode(Comic.self, from: data)
	}
	
	// Fetches the explanation of a comic from a given URL
	func fetchExplanation(from url: String) async throws -> ComicExplanationResponse {
		guard let url = URL(string: url) else {
			throw URLError(.badURL)
		}
		let (data, _) = try await URLSession.shared.data(from: url)
		return try JSONDecoder().decode(ComicExplanationResponse.self, from: data)
	}
	
	// Fetches a random comic between the first and the latest comic
	func fetchRandomComic(latestComicNumber: Int) async throws -> Comic {
		let randomComicNumber = Int.random(in: 1...latestComicNumber)
		return try await fetchComic(from: APIString.comicURL(comicNumber: randomComicNumber))
	}
	
	// Fetches the first result of a search query
	func fetchComicBySearch(query: String) async throws -> [Int] {
		guard let url = URL(string: APIString.searchURL) else {
			throw URLError(.badURL)
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let requestBody: [String: Any] = [
			"searches": [
				[
					"collection": "xkcd",
					"q": query,
					"query_by": "title,altTitle,transcript"
				]
			]
		]
		
		request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
		
		let (data, _) = try await URLSession.shared.data(for: request)
		let result = try JSONDecoder().decode(TypesenseResponse.self, from: data)
		
		let comicNumbers = result.results.first?.hits.compactMap { hit in
			Int(hit.document.id)
		} ?? []
		
		return comicNumbers
	}

}
