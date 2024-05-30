//
//  Explanation.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation

struct ComicExplanationResponse: Codable {
	struct Parse: Codable {
		struct WikiText: Codable {
			let text: String
			
			enum CodingKeys: String, CodingKey {
				case text = "*"
			}
		}
		
		let title: String
		let pageid: Int
		let wikitext: WikiText
	}
	
	let parse: Parse
}
