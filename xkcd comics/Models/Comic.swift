//
//  ComicModel.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation
import SwiftData

@Model
class Comic: Decodable, Identifiable {
	var month: String
	@Attribute(.unique) var num: Int
	var link: String
	var year: String
	var news: String
	var safeTitle: String
	var transcript: String
	var alt: String
	var img: String
	var title: String
	var day: String
	
	enum CodingKeys: String, CodingKey {
		case month, num, link, year, news
		case safeTitle = "safe_title"
		case transcript, alt, img, title, day
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.month = try container.decode(String.self, forKey: .month)
		self.num = try container.decode(Int.self, forKey: .num)
		self.link = try container.decode(String.self, forKey: .link)
		self.year = try container.decode(String.self, forKey: .year)
		self.news = try container.decode(String.self, forKey: .news)
		self.safeTitle = try container.decode(String.self, forKey: .safeTitle)
		self.transcript = try container.decode(String.self, forKey: .transcript)
		self.alt = try container.decode(String.self, forKey: .alt)
		self.img = try container.decode(String.self, forKey: .img)
		self.title = try container.decode(String.self, forKey: .title)
		self.day = try container.decode(String.self, forKey: .day)
	}
}
