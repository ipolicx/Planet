import AVKit
import Foundation
import SwiftUI

class MyArticleModel: ArticleModel, Codable {
    @Published var articleType: ArticleType? = .blog

    @Published var link: String
    @Published var slug: String? = nil
    @Published var heroImage: String? = nil
    @Published var externalLink: String? = nil

    @Published var summary: String? = nil

    @Published var isIncludedInNavigation: Bool? = false
    @Published var navigationWeight: Int? = 1

    var cids: [String: String]? = [:]

    var tags: [String: String]? = nil

    // populated when initializing
    unowned var planet: MyPlanetModel! = nil
    var draft: DraftModel? = nil

    lazy var path = planet.articlesPath.appendingPathComponent(
        "\(id.uuidString).json",
        isDirectory: false
    )
    lazy var publicBasePath = planet.publicBasePath.appendingPathComponent(
        id.uuidString,
        isDirectory: true
    )
    lazy var publicIndexPath = publicBasePath.appendingPathComponent(
        "index.html",
        isDirectory: false
    )
    lazy var publicSimplePath = publicBasePath.appendingPathComponent(
        "simple.html",
        isDirectory: false
    )
    lazy var publicMarkdownPath = publicBasePath.appendingPathComponent(
        "article.md",
        isDirectory: false
    )
    lazy var publicCoverImagePath = publicBasePath.appendingPathComponent(
        "_cover.png",
        isDirectory: false
    )
    lazy var publicInfoPath = publicBasePath.appendingPathComponent(
        "article.json",
        isDirectory: false
    )
    lazy var publicNFTMetadataPath = publicBasePath.appendingPathComponent(
        "nft.json",
        isDirectory: false
    )

    var publicArticle: PublicArticleModel {
        PublicArticleModel(
            articleType: articleType ?? .blog,
            id: id,
            link: {
                if let slug = slug, slug.count > 0 {
                    return "/\(slug)/"
                }
                return link
            }(),
            slug: slug ?? "",
            externalLink: externalLink ?? "",
            title: title,
            content: content,
            created: created,
            hasVideo: hasVideo,
            videoFilename: videoFilename,
            hasAudio: hasAudio,
            audioFilename: audioFilename,
            audioDuration: getAudioDuration(name: audioFilename),
            audioByteLength: getAttachmentByteLength(name: audioFilename),
            attachments: attachments,
            heroImage: socialImageURL?.absoluteString,
            cids: cids,
            tags: tags
        )
    }
    var localGatewayURL: URL? {
        return URL(string: "\(IPFSDaemon.shared.gateway)/ipns/\(planet.ipns)/\(id.uuidString)/")
    }
    var localPreviewURL: URL? {
        // If API is enabled, use the API URL
        // Otherwise, use the local gateway URL
        let apiEnabled = UserDefaults.standard.bool(forKey: String.settingsAPIEnabled)
        if apiEnabled {
            let apiPort =
                UserDefaults
                .standard.string(forKey: String.settingsAPIPort) ?? "9191"
            return URL(
                string:
                    "http://127.0.0.1:\(apiPort)/v0/planets/my/\(planet.id.uuidString)/public/\(id.uuidString)/index.html"
            )
        }
        else {
            return localGatewayURL
        }
    }
    var browserURL: URL? {
        var urlPath = "/\(id.uuidString)/"
        if let slug = slug, slug.count > 0 {
            urlPath = "/\(slug)/"
        }
        if let domain = planet.domain {
            if domain.hasSuffix(".eth") {
                return URL(string: "https://\(domain).limo\(urlPath)")
            }
            if domain.hasSuffix(".bit") {
                return URL(string: "https://\(domain).cc\(urlPath)")
            }
            if domain.hasCommonTLDSuffix() {
                return URL(string: "https://\(domain)\(urlPath)")
            }
        }
        return URL(string: "\(IPFSDaemon.preferredGateway())/ipns/\(planet.ipns)\(urlPath)")
    }
    var socialImageURL: URL? {
        if let heroImage = getHeroImage(), let baseURL = browserURL {
            return baseURL.appendingPathComponent(heroImage)
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case id, articleType,
            link, slug, heroImage, externalLink,
            title, content, summary,
            created, starred, starType,
            videoFilename, audioFilename,
            attachments, cids, tags,
            isIncludedInNavigation,
            navigationWeight
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        if let articleType = try container.decodeIfPresent(ArticleType.self, forKey: .articleType) {
            self.articleType = articleType
        }
        else {
            self.articleType = .blog
        }
        link = try container.decode(String.self, forKey: .link)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        heroImage = try container.decodeIfPresent(String.self, forKey: .heroImage)
        externalLink = try container.decodeIfPresent(String.self, forKey: .externalLink)
        let title = try container.decode(String.self, forKey: .title)
        let content = try container.decode(String.self, forKey: .content)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        isIncludedInNavigation =
            try container.decodeIfPresent(Bool.self, forKey: .isIncludedInNavigation) ?? false
        navigationWeight = try container.decodeIfPresent(Int.self, forKey: .navigationWeight)
        let created = try container.decode(Date.self, forKey: .created)
        let starred = try container.decodeIfPresent(Date.self, forKey: .starred)
        let starType: ArticleStarType =
            try container.decodeIfPresent(ArticleStarType.self, forKey: .starType) ?? .star
        let videoFilename = try container.decodeIfPresent(String.self, forKey: .videoFilename)
        let audioFilename = try container.decodeIfPresent(String.self, forKey: .audioFilename)
        let attachments = try container.decodeIfPresent([String].self, forKey: .attachments)
        cids = try? container.decodeIfPresent([String: String].self, forKey: .cids) ?? [:]
        tags = try? container.decodeIfPresent([String: String].self, forKey: .tags) ?? [:]
        super.init(
            id: id,
            title: title,
            content: content,
            created: created,
            starred: starred,
            starType: starType,
            videoFilename: videoFilename,
            audioFilename: audioFilename,
            attachments: attachments
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(articleType, forKey: .articleType)
        try container.encode(link, forKey: .link)
        try container.encodeIfPresent(slug, forKey: .slug)
        try container.encodeIfPresent(heroImage, forKey: .heroImage)
        try container.encodeIfPresent(externalLink, forKey: .externalLink)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(summary, forKey: .summary)
        try container.encodeIfPresent(isIncludedInNavigation, forKey: .isIncludedInNavigation)
        try container.encodeIfPresent(navigationWeight, forKey: .navigationWeight)
        try container.encode(created, forKey: .created)
        try container.encodeIfPresent(starred, forKey: .starred)
        try container.encodeIfPresent(starType, forKey: .starType)
        try container.encodeIfPresent(videoFilename, forKey: .videoFilename)
        try container.encodeIfPresent(audioFilename, forKey: .audioFilename)
        try container.encodeIfPresent(attachments, forKey: .attachments)
        try container.encodeIfPresent(cids, forKey: .cids)
        try container.encodeIfPresent(tags, forKey: .tags)
    }

    init(
        id: UUID,
        link: String,
        slug: String? = nil,
        heroImage: String? = nil,
        externalLink: String? = nil,
        title: String,
        content: String,
        summary: String?,
        created: Date,
        starred: Date?,
        starType: ArticleStarType,
        videoFilename: String?,
        audioFilename: String?,
        attachments: [String]?,
        isIncludedInNavigation: Bool? = false,
        navigationWeight: Int? = 1
    ) {
        self.link = link
        self.slug = slug
        self.heroImage = heroImage
        self.externalLink = externalLink
        self.summary = summary
        self.isIncludedInNavigation = isIncludedInNavigation
        self.navigationWeight = navigationWeight
        super.init(
            id: id,
            title: title,
            content: content,
            created: created,
            starred: starred,
            starType: starType,
            videoFilename: videoFilename,
            audioFilename: audioFilename,
            attachments: attachments
        )
    }

    static func load(from filePath: URL, planet: MyPlanetModel) throws -> MyArticleModel {
        let filename = (filePath.lastPathComponent as NSString).deletingPathExtension
        guard let id = UUID(uuidString: filename) else {
            throw PlanetError.PersistenceError
        }
        let articleData = try Data(contentsOf: filePath)
        let article = try JSONDecoder.shared.decode(MyArticleModel.self, from: articleData)
        guard article.id == id else {
            throw PlanetError.PersistenceError
        }
        article.planet = planet
        let draftPath = planet.articleDraftsPath.appendingPathComponent(
            id.uuidString,
            isDirectory: true
        )
        if FileManager.default.fileExists(atPath: draftPath.path) {
            article.draft = try? DraftModel.load(from: draftPath, article: article)
        }
        return article
    }

    static func compose(
        link: String?,
        date: Date = Date(),
        title: String,
        content: String,
        summary: String?,
        planet: MyPlanetModel
    ) throws -> MyArticleModel {
        let id = UUID()
        let article = MyArticleModel(
            id: id,
            link: link ?? "/\(id.uuidString)/",
            title: title,
            content: content,
            summary: summary,
            created: date,
            starred: nil,
            starType: .star,
            videoFilename: nil,
            audioFilename: nil,
            attachments: nil
        )
        article.planet = planet
        try FileManager.default.createDirectory(
            at: article.publicBasePath,
            withIntermediateDirectories: true
        )
        return article
    }

    // MARK: Attachment

    /// Get the on-disk URL of an attachment from its file name.
    func getAttachmentURL(name: String) -> URL? {
        let path = publicBasePath.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: path.path) {
            return path
        }
        return nil
    }

    /// If the article:
    ///   - Has no attachments
    ///   - Is not a page
    ///   - Not included in navigation
    /// Used by article item view.
    func hasNoSpecialContent() -> Bool {
        let attachmentsCount = self.attachments?.count ?? 0
        let isPage = self.articleType == .page ? true : false
        let isIncludedInNavigation = self.isIncludedInNavigation ?? false
        return attachmentsCount == 0 && !isPage && !isIncludedInNavigation
    }
}

extension MyArticleModel {
    static var placeholder: MyArticleModel {
        MyArticleModel(
            id: UUID(),
            link: "/example/",
            slug: "/example/",
            heroImage: nil,
            externalLink: nil,
            title: "Example Article",
            content: "This is an example article.",
            summary: "This is an example article.",
            created: Date(),
            starred: nil,
            starType: .star,
            videoFilename: nil,
            audioFilename: nil,
            attachments: nil
        )
    }

    func toggleToDoItem(item: String) {
        let components = item.split(separator: "-")
        guard let lastComponent = components.last else { return }
        guard let idx = Int(lastComponent) else { return }

        var lines = self.content.components(separatedBy: .newlines)
        var i = 0
        var found = false
        for (index, line) in lines.enumerated() {
            if line.starts(with: "- [ ] ") {
                i = i + 1
                if i == idx {
                    lines[index] = line.replacingOccurrences(of: "- [ ]", with: "- [x]")
                    found = true
                }
            }
            else if line.starts(with: "- [x] ") {
                i = i + 1
                if i == idx {
                    lines[index] = line.replacingOccurrences(of: "- [x]", with: "- [ ]")
                    found = true
                }
            }
        }
        if found {
            self.content = lines.joined(separator: "\n")
            do {
                try self.save()
                Task {
                    try self.savePublic()
                    NotificationCenter.default.post(name: .loadArticle, object: nil)
                }
                debugPrint("TODO item toggled and saved for \(self.title)")
            }
            catch {
                debugPrint("TODO item toggled but failed to save for \(self.title): \(error)")
            }
        }
        else {
            debugPrint("TODO item not found for \(self.title)")
        }
    }
}

struct NFTMetadata: Codable {
    let name: String
    let description: String
    let image: String
    let external_url: String
    let mimeType: String
    let animation_url: String?
    let attributes: [NFTAttribute]?
}

struct NFTAttribute: Codable {
    let trait_type: String
    let value: String
}
