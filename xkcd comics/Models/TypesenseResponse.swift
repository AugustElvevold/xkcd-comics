//
//  TypesenseResponse.swift
//  xkcd comics
//
//  Created by August Elvevold on 01/06/2024.
//

import Foundation

// Typesense is the open source engine that powers the searchfunctionality.
// This struct is used to decode the JSON response from Typesense.

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
