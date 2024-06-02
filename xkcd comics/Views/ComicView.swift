//
//  ComicView.swift
//  xkcd comics
//
//  Created by August Elvevold on 02/06/2024.
//

import SwiftUI

struct ComicView: View {
	var comic: Comic
	var saveAction: () -> Void
	var showExplanationAction: () -> Void
	@Bindable var comicViewModel: ComicViewModel
	@Binding var selectedComic: Comic?
	
	var body: some View {
		VStack {
			Text(comic.title)
				.font(.headline)
				.padding()
			AsyncImage(url: URL(string: comic.img)) { phase in
				switch phase {
					case .empty:
						ProgressView()
							.frame(width: 300, height: 300)
							.padding()
					case .success(let image):
						image
							.resizable()
							.scaledToFit()
							.frame(maxWidth: 300, maxHeight: 300)
					case .failure:
						Image(systemName: "photo")
							.resizable()
							.scaledToFit()
							.frame(maxWidth: 300, maxHeight: 300)
					@unknown default:
						EmptyView()
				}
			}
			HStack {
				Text("Comic number: " + String(comic.num))
					.font(.caption)
				Spacer()
				Text(formatNorwegianDate(comic.day, comic.month, comic.year))
					.font(.caption)
			}
			.padding(.horizontal)
			Text(comic.alt)
				.font(.subheadline)
				.padding()
			HStack {
				Spacer()
				Button(action: saveAction) {
					Label("Save", systemImage: "bookmark")
				}
				.tint(.blue)
				let urlString = "https://xkcd.com/" + String(comic.num)
				if let url = URL(string: urlString) {
					ShareLink(item: url) {
						Label("Share", systemImage: "square.and.arrow.up")
					}
					.tint(.blue)
				}
				Button(action: {
					selectedComic = comic
					showExplanationAction()
				}) {
					Label("See explanation", systemImage: "questionmark.circle")
				}
				.tint(.blue)
			}
			.padding(.horizontal)
		}
		.onAppear {
			if comic == comicViewModel.currentComics.last {
				Task {
					await comicViewModel.loadMoreComics(filter: comicViewModel.selectedFilter)
				}
			}
		}
	}
	
	// Formats three strings representing a day, month, and year to a Norwegian date format
	func formatNorwegianDate(_ day: String, _ month: String, _ year: String) -> String {
		// Create a DateFormatter
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nb_NO") // Norwegian locale
		dateFormatter.dateFormat = "d. MMMM yyyy"
		
		// Convert string numbers to integers
		guard let dayInt = Int(day), let monthInt = Int(month), let yearInt = Int(year) else {
			return "Invalid date"
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
			return "Invalid date"
		}
	}
}

