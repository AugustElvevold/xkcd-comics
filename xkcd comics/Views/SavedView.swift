//
//  SavedView.swift
//  xkcd comics
//
//  Created by August Elvevold on 30/05/2024.
//

import SwiftUI
import SwiftData

struct SavedView: View {
	@Query var savedComics: [Comic]
	var body: some View {
		if(savedComics.isEmpty) {
			Text("No saved comics")
				.padding()
		} else {
			
			List {
				ForEach(savedComics) { comic in
					Text(comic.title)
					AsyncImage(url: URL(string: comic.img)) { phase in
						switch phase {
							case .empty:
								ProgressView()
									.frame(width: 30, height: 30)
									.padding()
							case .success(let image):
								image
									.resizable()
									.scaledToFit()
									.frame(maxWidth: 30, maxHeight: 30)
							case .failure:
								Image(systemName: "photo")
									.resizable()
									.scaledToFit()
									.frame(maxWidth: 30, maxHeight: 30)
							@unknown default:
								EmptyView()
						}
					}
					.padding()
				}
			}
			.navigationTitle("Saved comics")
		}
	}
}

#Preview {
	SavedView()
		.modelContainer(for: Comic.self)
}
