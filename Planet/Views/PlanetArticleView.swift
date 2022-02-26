//
//  PlanetArticleView.swift
//  Planet
//
//  Created by Kai on 1/15/22.
//

import SwiftUI
import WebKit


struct PlanetArticleView: View {
    @EnvironmentObject private var planetStore: PlanetStore

    var article: PlanetArticle!
    
    @State private var url: URL = Bundle.main.url(forResource: "TemplatePlaceholder.html", withExtension: "")!

    var body: some View {
        VStack {
            if let article = article, let id = planetStore.selectedArticle, article.id != nil, id == article.id!.uuidString {
                SimplePlanetArticleView(url: $url)
                    .task(priority: .utility) {
                        if let urlPath = await PlanetManager.shared.articleURL(article: article) {
                            url = urlPath
                        } else {
                            DispatchQueue.main.async {
                                self.planetStore.currentArticle = nil
                                self.planetStore.selectedArticle = UUID().uuidString
                                self.planetStore.isFailedAlert = true
                                self.planetStore.failedAlertTitle = "Failed to load article"
                                self.planetStore.failedAlertMessage = "Please try again later."
                            }
                        }
                    }
            } else {
                Text("No Article Selected")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(planetStore.currentPlanet == nil ? "Planet" : planetStore.currentPlanet.name ?? "Planet")
    }
}