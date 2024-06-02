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
	
	var randomComics: [Comic] = []
	var newestComics: [Comic] = []
	var oldestComics: [Comic] = []
	var searchResultComics: [Comic] = []
	var currentComics: [Comic] {
		switch selectedFilter {
			case .random:
				return randomComics
			case .newest:
				return newestComics
			case .oldest:
				return oldestComics
		}
	}
	
	var selectedFilter: FilterType = .newest
	var errorMessage: String?
	var newestComicNumber: Int?
	var newestComic: Bool {
		currentComicNumber == newestComicNumber
	}
	var oldestComic: Bool {
		currentComicNumber == 1
	}
	var isLoading: Bool = false
	
	func handleFilterChange() {
		switch selectedFilter {
			case .random:
				if randomComics.isEmpty {
					Task {
						await fetchRandomComic()
					}
				}
			case .newest:
				if newestComics.isEmpty {
					Task {
						await fetchNewestComic()
					}
				}
			case .oldest:
				if oldestComics.isEmpty {
					Task {
						await fetchOldestComic()
					}
				}
		}
	}
	
	// Fetch the latest comic
	func fetchNewestComic() async {
		isLoading = true
		do {
			let comic = try await apiService.fetchComic(from: APIString.latestComicURL)
			DispatchQueue.main.async {
				self.newestComics = [comic]
				self.newestComicNumber = comic.num
				self.currentComicNumber = comic.num
				self.isLoading = false
				print("Fetched newest comic: \(comic.title)")
			}
		} catch {
			DispatchQueue.main.async {
				self.errorMessage = error.localizedDescription
				self.isLoading = false
			}
		}
	}
	
	// Fetch the first comic
	func fetchOldestComic() async {
		isLoading = true
		do {
			let comic = try await apiService.fetchComic(from: APIString.comicURL(comicNumber: 1))
			DispatchQueue.main.async {
				self.oldestComics = [comic]
				self.isLoading = false
				print("Fetched oldest comic: \(comic.title)")
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
				self.searchResultComics = [comic]
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
	
	// Fetch multiple comics by their numbers
	func fetchComicsByNumbers(numbers: [Int]) async {
		isLoading = true
		do {
			let comics = try await withThrowingTaskGroup(of: Comic.self) { group -> [Comic] in
				var fetchedComics: [Comic] = []
				
				for number in numbers {
					group.addTask {
						return try await self.apiService.fetchComic(from: APIString.comicURL(comicNumber: number))
					}
				}
				
				for try await comic in group {
					fetchedComics.append(comic)
				}
				
				return fetchedComics
			}
			
			DispatchQueue.main.async {
				self.searchResultComics = comics
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
			let comicNumbers = try await apiService.fetchComicBySearch(query: query)
			if comicNumbers.isEmpty {
				DispatchQueue.main.async {
					self.errorMessage = "No comic found."
					self.isLoading = false
				}
				return
			}
			
			// Fetch all comics by their numbers
			await fetchComicsByNumbers(numbers: comicNumbers)
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
			if newestComicNumber == nil {
				await fetchNewestComic()
			}
			guard let latestComicNumber = newestComicNumber else { return }
			let comic = try await apiService.fetchRandomComic(latestComicNumber: latestComicNumber)
			DispatchQueue.main.async {
				self.randomComics.append(comic)
				self.currentComicNumber = comic.num
				self.isLoading = false
				print("Fetched random comic: \(comic.title)")
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
		if (oldestComic) { return }
		isLoading = true
		do {
			if currentComicNumber == nil {
				await fetchNewestComic()
			}
			guard let currentComicNumber = currentComicNumber else { return }
			let previousComicNumber = currentComicNumber - 1
			let comic = try await apiService.fetchComic(from: APIString.comicURL(comicNumber: previousComicNumber))
			DispatchQueue.main.async {
				self.newestComics.append(comic)
				self.currentComicNumber = comic.num
				self.isLoading = false
				print("Fetched previous comic: \(comic.title)")
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
		if (newestComic) { return }
		isLoading = true
		do {
			if currentComicNumber == nil {
				await fetchNewestComic()
			}
			guard let currentComicNumber = currentComicNumber else { return }
			let nextComicNumber = currentComicNumber + 1
			let comic = try await apiService.fetchComic(from: APIString.comicURL(comicNumber: nextComicNumber))
			DispatchQueue.main.async {
				self.oldestComics.append(comic)
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
				if let index = self.newestComics.firstIndex(where: { $0.num == comicNumber }) {
					self.newestComics[index].explanation = cleanedExplanation
				}
				if let index = self.oldestComics.firstIndex(where: { $0.num == comicNumber }) {
					self.oldestComics[index].explanation = cleanedExplanation
				}
				if let index = self.randomComics.firstIndex(where: { $0.num == comicNumber }) {
					self.randomComics[index].explanation = cleanedExplanation
				}
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
	
	func loadMoreComics(filter: FilterType) async {
		switch filter {
			case .random:
				await fetchRandomComic()
			case .newest:
				await fetchPreviousComic()
			case .oldest:
				await fetchNextComic()
		}
	}
}

enum FilterType: String, CaseIterable {
	case random = "Random"
	case newest = "Newest"
	case oldest = "Oldest"
}
