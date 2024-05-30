//
//  ComicViewModel.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import Foundation
import Observation
import Combine

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
	
	func fetchExplanation(for comicNumber: Int, comicTitle: String) {
		print("Fetching explanation for comic \(comicNumber)")
		let comicTitleFormatted = comicTitle.replacingOccurrences(of: " ", with: "_")
		let urlString = "https://www.explainxkcd.com/wiki/api.php?action=parse&page=\(comicNumber):_\(comicTitleFormatted)&prop=wikitext&sectiontitle=Explanation&format=json"
		print("Fetching explanation from: \(urlString)")
		guard let url = URL(string: urlString) else {
			self.errorMessage = "Invalid URL"
			return
		}
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.errorMessage = error.localizedDescription
				}
				return
			}
			
			guard let data = data else {
				DispatchQueue.main.async {
					self.errorMessage = "No data found"
				}
				return
			}
			
			do {
				let response = try JSONDecoder().decode(ComicExplanationResponse.self, from: data)
				let wikitext = response.parse.wikitext.text
				let explanation = self.extractExplanation(from: wikitext)
				let cleanedExplanation = self.cleanWikitext(explanation)
				DispatchQueue.main.async {
					self.comics.first!.explanation = cleanedExplanation
				}
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = error.localizedDescription
				}
			}
		}.resume()
	}
	
	private func extractExplanation(from wikitext: String) -> String {
		let explanationStart = "==Explanation=="
		let transcriptStart = "==Transcript=="
		
		if let explanationRange = wikitext.range(of: explanationStart),
			 let transcriptRange = wikitext.range(of: transcriptStart) {
			let explanationText = wikitext[explanationRange.upperBound..<transcriptRange.lowerBound]
			return String(explanationText).trimmingCharacters(in: .whitespacesAndNewlines)
		}
		
		return "Explanation not found."
	}
	
	private func cleanWikitext(_ text: String) -> String {
		var cleanedText = text
		
		// Remove citations {{citation}}
		cleanedText = cleanedText.replacingOccurrences(of: "\\{\\{citation.*?\\}\\}", with: "", options: .regularExpression)
		
		// Remove categories [[:Category:something]]
		cleanedText = cleanedText.replacingOccurrences(of: "\\[\\[:Category:.*?\\]\\]", with: "", options: .regularExpression)
		
		// Remove {{incomplete| ****}}
		cleanedText = cleanedText.replacingOccurrences(of: "\\{\\{incomplete.*?\\}\\}", with: "", options: .regularExpression)
		
		// Replace links [[link|text]] with text or [[text]] with text
		cleanedText = cleanedText.replacingOccurrences(of: "\\[\\[(?:[^|\\]]*\\|)?([^|\\]]+)\\]\\]", with: "$1", options: .regularExpression)
		
		// Remove {{w|text}} formatting
		cleanedText = cleanedText.replacingOccurrences(of: "\\{\\{w\\|([^|\\]]+)\\}\\}", with: "$1", options: .regularExpression)
		
		// Replace {{w|text1|text2}} with text1
		cleanedText = cleanedText.replacingOccurrences(of: "\\{\\{w\\|([^|\\]]+)\\|([^|\\]]+)\\}\\}", with: "$1", options: .regularExpression)
		
		// Replace {{w|text1|text2|text3}} with text1
		cleanedText = cleanedText.replacingOccurrences(of: "\\{\\{w\\|([^|\\]]+)\\|([^|\\]]+)\\|([^|\\]]+)\\}\\}", with: "$1", options: .regularExpression)
		
		// Remove <br> tags
		cleanedText = cleanedText.replacingOccurrences(of: "<br>", with: "")
		
		// Remove HTML links but keep the text
		cleanedText = cleanedText.replacingOccurrences(of: "\\[https?://[^\\s]*\\s([^\\]]+)\\]", with: "$1", options: .regularExpression)
		
		// Remove multiline HTML links but keep the text
		cleanedText = cleanedText.replacingOccurrences(of: "\\[https?://[^\\s]*\\s([^\\]]+)]\\s*\\n\\[https?://[^\\s]*\\s([^\\]]+)\\]", with: "$1 $2", options: .regularExpression)
		
		return cleanedText
	}
	
	func formatNorwegianDate(_ day: String, _ month: String, _ year: String) -> String? {
		// Create a DateFormatter
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nb_NO") // Norwegian locale
		dateFormatter.dateFormat = "d. MMMM yyyy"
		
		// Convert string numbers to integers
		guard let dayInt = Int(day), let monthInt = Int(month), let yearInt = Int(year) else {
			return nil
		}
		
		// Create DateComponents
		var dateComponents = DateComponents()
		dateComponents.day = dayInt
		dateComponents.month = monthInt
		dateComponents.year = yearInt
		
		// Get the calendar and convert DateComponents to Date
		let calendar = Calendar.current
		if let date = calendar.date(from: dateComponents) {
			// Format the date to the desired string format
			return dateFormatter.string(from: date)
		} else {
			return nil
		}
	}
}
