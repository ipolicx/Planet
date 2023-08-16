import SwiftUI

enum ListViewFilter: String, CaseIterable {
    case all = "All"
    case pages = "Pages"
    case nav = "Navigation Items"
    case unread = "Unread"
    case starred = "Starred"

    case star = "Star"

    case plan = "Plan"
    case todo = "To Do"
    case done = "Done"

    case sparkles = "Sparkles"
    case heart = "Heart"
    case question = "Question"
    case paperplane = "Paperplane"

    static let buttonLabels: [String: String] = [
        "All": "Show All".localized,
        "Pages": "Show Pages".localized,
        "Navigation Items": "Show Navigation Items".localized,
        "Unread": "Show Unread".localized,
        "Starred": "Show All Starred".localized,
    ]

    static let emptyLabels: [String: String] = [
        "All": "No Articles".localized,
        "Pages": "No Pages".localized,
        "Navigation Items": "No Navigation Items".localized,
        "Unread": "No Unread Articles".localized,
        "Starred": "No Starred Articles".localized,
        "Star": "No Starred Articles".localized,
        "Plan": "No Items with Plan Type".localized,
        "To Do": "No Items with To Do Type".localized,
        "Done": "No Items with Done Type".localized,
        "Sparkles": "No Items with Sparkles Type".localized,
        "Heart": "No Items with Heart Type".localized,
        "Question": "No Items with Question Type".localized,
        "Paperplane": "No Items with Paperplane Type".localized,
    ]

    static let imageNames: [String: String] = [
        "All": "line.3.horizontal.circle",
        "Pages": "doc.text",
        "Navigation Items": "link.circle",
        "Unread": "line.3.horizontal.circle.fill",
        "Starred": "star.fill",
        "Star": "star.fill",
        "Plan": "circle.dotted",
        "To Do": "circle",
        "Done": "checkmark.circle.fill",
        "Sparkles": "sparkles",
        "Heart": "heart.fill",
        "Question": "questionmark.circle.fill",
        "Paperplane": "paperplane.circle.fill",
    ]
}

struct ArticleListView: View {
    @EnvironmentObject var planetStore: PlanetStore
    @State var filter: ListViewFilter = .all
    @State var articles: [ArticleModel]? = []

    private func filterArticles(_ articles: [ArticleModel]) -> [ArticleModel]? {
        switch filter {
        case .all:
            return articles
        case .pages:
            return articles.filter {
                if let myArticle = $0 as? MyArticleModel {
                    return myArticle.articleType == .page
                }
                return false
            }
        case .nav:
            return articles.filter {
                if let myArticle = $0 as? MyArticleModel,
                    let isIncludedInNavigation = myArticle.isIncludedInNavigation
                {
                    return isIncludedInNavigation
                }
                return false
            }
        case .unread:
            return articles.filter {
                if let followingArticle = $0 as? FollowingArticleModel {
                    return followingArticle.read == nil
                }
                return false
            }
        case .starred:
            return articles.filter { $0.starred != nil }
        case .star:
            return articles.filter { $0.starred != nil && $0.starType == .star }
        case .plan:
            return articles.filter { $0.starred != nil && $0.starType == .plan }
        case .todo:
            return articles.filter { $0.starred != nil && $0.starType == .todo }
        case .done:
            return articles.filter { $0.starred != nil && $0.starType == .done }
        case .sparkles:
            return articles.filter { $0.starred != nil && $0.starType == .sparkles }
        case .heart:
            return articles.filter { $0.starred != nil && $0.starType == .heart }
        case .question:
            return articles.filter { $0.starred != nil && $0.starType == .question }
        case .paperplane:
            return articles.filter { $0.starred != nil && $0.starType == .paperplane }
        }
    }

    @ViewBuilder
    private func FilterIndicatorView(filter: ListViewFilter) -> some View {
        Image(systemName: ListViewFilter.imageNames[filter.rawValue] ?? "line.3.horizontal.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20, alignment: .center)
    }

    var body: some View {
        VStack {
            if let articles = articles {
                if articles.isEmpty {
                    Text(ListViewFilter.emptyLabels[filter.rawValue] ?? "No Articles")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14, weight: .regular))
                }
                else {
                    List(articles, id: \.self, selection: $planetStore.selectedArticle) { article in
                        if let myArticle = article as? MyArticleModel {
                            if #available(macOS 13.0, *) {
                                MyArticleItemView(article: myArticle)
                                    .listRowSeparator(.visible)
                            } else {
                                MyArticleItemView(article: myArticle)
                            }
                        }
                        else if let followingArticle = article as? FollowingArticleModel {
                            if #available(macOS 13.0, *) {
                                FollowingArticleItemView(article: followingArticle)
                                    .listRowSeparator(.visible)
                            } else {
                                FollowingArticleItemView(article: followingArticle)
                            }
                        }
                    }
                }
            }
            else {
                Text("No Planet Selected")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14, weight: .regular))
            }
        }
        .navigationTitle(
            Text(planetStore.navigationTitle)
        )
        .navigationSubtitle(
            Text(planetStore.navigationSubtitle)
        )
        .frame(minWidth: 240, maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.textBackgroundColor))
        .toolbar {
            Menu {
                ForEach(ListViewFilter.allCases, id: \.self) { aFilter in
                    Button {
                        filter = aFilter
                    } label: {
                        HStack {
                            if filter == aFilter {
                                Image(systemName: "checkmark")
                            }
                            else {
                                Image(
                                    systemName: ListViewFilter.imageNames[aFilter.rawValue]
                                        ?? "line.3.horizontal.circle"
                                )
                            }
                            Text(ListViewFilter.buttonLabels[aFilter.rawValue] ?? aFilter.rawValue)
                        }
                    }
                    if aFilter == .starred || aFilter == .star || aFilter == .done {
                        Divider()
                    }
                }
            } label: {
                FilterIndicatorView(filter: filter)
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 1, trailing: 0))
            .frame(width: 40, height: 20, alignment: .leading)
            .menuIndicator(.hidden)
            .help(filter.rawValue)
        }
        .onAppear {
            articles = filterArticles(planetStore.selectedArticleList ?? [])
        }
        .onChange(of: planetStore.selectedArticleList) { newValue in
            articles = filterArticles(planetStore.selectedArticleList ?? [])
        }
        .onChange(of: filter) { newValue in
            articles = filterArticles(planetStore.selectedArticleList ?? [])
        }
        .onReceive(NotificationCenter.default.publisher(for: .followingArticleReadChanged)) {
            aNotification in
            if let userObject = aNotification.object,
                let article = userObject as? FollowingArticleModel, let planet = article.planet
            {
                debugPrint("FollowingArticleReadChanged: \(planet.name) -> \(article.title)")
                Task { @MainActor in
                    switch planetStore.selectedView {
                    case .unread:
                        debugPrint("Setting the new navigation subtitle for Unread")
                        if let articles = planetStore.selectedArticleList?.filter({ item in
                            if let followingArticle = item as? FollowingArticleModel {
                                return followingArticle.read == nil
                            }
                            return false
                        }) {
                            planetStore.navigationSubtitle = "\(articles.count) unread"
                        }
                    case .followingPlanet(let planet):
                        planetStore.navigationSubtitle = planet.navigationSubtitle()
                    default:
                        break
                    }

                }
            }
        }
    }
}
