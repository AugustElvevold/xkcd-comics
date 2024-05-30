//
//  SearchService.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation

struct TypesenseResponse: Codable {
	let results: [SearchResult]
}

struct SearchResult: Codable {
	let hits: [Hit]
}

struct Hit: Codable {
	let document: findxkcdModel
}

struct findxkcdModel: Codable {
	let id: String
	let title: String
	let altTitle: String?
	let imageUrl: String?
	let publishDateDay: Int?
	let publishDateMonth: Int?
	let publishDateYear: Int?
	let topics: [String]?
	let transcript: String?
}

class XKCDSearchService {
	private let apiKey = "8hLCPSQTYcBuK29zY5q6Xhin7ONxHy99"
	private let urlString = "https://qtg5aekc2iosjh93p.a1.typesense.net/multi_search?use_cache=true&x-typesense-api-key="
	
	func searchFirstComicID(query: String) -> Int? {
		let semaphore = DispatchSemaphore(value: 0)
		var comicID: String?
		
		guard let url = URL(string: urlString + apiKey) else {
			return nil
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
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
		} catch {
			return nil
		}
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				semaphore.signal()
				return
			}
			
			do {
				let result = try JSONDecoder().decode(TypesenseResponse.self, from: data)
				comicID = result.results.first?.hits.first?.document.id
			} catch {
				comicID = nil
			}
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		let comicNum = Int(comicID ?? "")
		
		return comicNum
	}
}
