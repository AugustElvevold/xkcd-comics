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
	private var currentComicNumber: Int?
	private let apiService = APIService()
	
	var comics: [Comic] = []
	var errorMessage: String?
	var latestComicNumber: Int?
	var latestComic: Bool {
		currentComicNumber == latestComicNumber
	}
	var firstComic: Bool {
		currentComicNumber == 1
	}
	var isLoading: Bool = false
	
	// Fetch the latest comic
	func fetchLatestComic() async {
		isLoading = true
		do {
			let comic = try await apiService.fetchComic(from: APIString.latestComicURL)
			DispatchQueue.main.async {
				self.comics = [comic]
				self.latestComicNumber = comic.num
				self.currentComicNumber = comic.num
				
				// Save the latest comic number to UserDefaults
				UserDefaults.standard.set(comic.num, forKey: "lastComicNum")
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch a comic by its number
	func fetchComicByNumber(number: Int) async {
		isLoading = true
		do {
			let comic = try await apiService.fetchComic(from: APIString.comicURL(comicNumber: number))
			DispatchQueue.main.async {
				self.comics = [comic]
				self.currentComicNumber = comic.num
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch a comic by searching for a query
	func fetchComicBySearch(query: String) async {
		isLoading = true
		do {
			guard let comicNumber = try await apiService.fetchComicBySearch(query: query) else {
				DispatchQueue.main.async {
					self.errorMessage = "No comic found."
					self.isLoading = false
				}
				return
			}
			
			// If a comic is found, fetch it by number to get the same type of object data
			await fetchComicByNumber(number: comicNumber)
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch a random comic
	func fetchRandomComic() async {
		isLoading = true
		do {
			if latestComicNumber == nil {
				await fetchLatestComic()
			}
			guard let latestComicNumber = latestComicNumber else { return }
			let comic = try await apiService.fetchRandomComic(latestComicNumber: latestComicNumber)
			DispatchQueue.main.async {
				self.comics = [comic]
				self.currentComicNumber = comic.num
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch the previous comic based on the current comic number if there are any
	func fetchPreviousComic() async {
		if (currentComicNumber == 1) { return }
		isLoading = true
		do {
			if currentComicNumber == nil {
				await fetchLatestComic()
			}
			guard let currentComicNumber = currentComicNumber else { return }
			let previousComicNumber = currentComicNumber - 1
			let comic = try await apiService.fetchComic(from: APIString.comicURL(comicNumber: previousComicNumber))
			DispatchQueue.main.async {
				self.comics = [comic]
				self.currentComicNumber = comic.num
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch the next comic based on the current comic number if there are any
	func fetchNextComic() async {
		if (currentComicNumber == latestComicNumber) { return }
		isLoading = true
		do {
			if currentComicNumber == nil {
				await fetchLatestComic()
			}
			guard let currentComicNumber = currentComicNumber else { return }
			let nextComicNumber = currentComicNumber + 1
			let comic = try await apiService.fetchComic(from: APIString.comicURL(comicNumber: nextComicNumber))
			DispatchQueue.main.async {
				self.comics = [comic]
				self.currentComicNumber = comic.num
				self.isLoading = false
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch the explanation of the current comic
	func fetchExplanation(for comicNumber: Int, comicTitle: String) async {
		do {
			let urlString = APIString.explanationURL(comicNumber: comicNumber, comicTitle: comicTitle)
			let response = try await apiService.fetchExplanation(from: urlString)
			let wikitext = response.parse.wikitext.text
			let explanation = extractExplanation(from: wikitext)
			let cleanedExplanation = cleanWikitext(explanation)
			DispatchQueue.main.async {
				self.comics.first?.explanation = cleanedExplanation
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
			}
		}
	}
	
	// Helper function to extract the explanation from the wikitext
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
	
	// Helper function to clean the wikitext
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
	
	// Formats three strings representing a day, month, and year to a Norwegian date format
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
