//
//  APIService.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation
import SwiftData

struct APIString {
	static let baseURL = "https://xkcd.com/"
	static let endURL = "/info.0.json"
	
	// Returns the URL for the latest comic
	static var latestComicURL: String {
		return "\(baseURL)info.0.json"
	}
	
	// Returns the URL for a specific comic number
	static func comicURL(comicNumber: Int) -> String {
		return "\(baseURL)\(comicNumber)\(endURL)"
	}
}
