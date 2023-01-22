import Foundation

// MARK: - Reviews
struct Reviews: Codable {
    let status, copyright: String?
    let hasMore: Bool?
    let numResults: Int?
    let results: [Review]?

    enum CodingKeys: String, CodingKey {
        case status, copyright
        case hasMore = "has_more"
        case numResults = "num_results"
        case results
    }
}

// MARK: - Review
struct Review: Codable {
    let displayTitle: String?
    let mpaaRating: String?
    let criticsPick: Int?
    let byline, headline, summaryShort, publicationDate: String?
    let openingDate: String?
    let dateUpdated: String?
    let link: Link?
    let multimedia: Multimedia?

    enum CodingKeys: String, CodingKey {
        case displayTitle = "display_title"
        case mpaaRating = "mpaa_rating"
        case criticsPick = "critics_pick"
        case byline, headline
        case summaryShort = "summary_short"
        case publicationDate = "publication_date"
        case openingDate = "opening_date"
        case dateUpdated = "date_updated"
        case link, multimedia
    }
}

// MARK: - Link
struct Link: Codable {
    let type: LinkType?
    let url: String?
    let suggestedLinkText: String?

    enum CodingKeys: String, CodingKey {
        case type, url
        case suggestedLinkText = "suggested_link_text"
    }
}

enum LinkType: String, Codable {
    case article = "article"
}

// MARK: - Multimedia
struct Multimedia: Codable {
    let type: MultimediaType?
    let src: String?
    let height, width: Int?
}

enum MultimediaType: String, Codable {
    case mediumThreeByTwo210 = "mediumThreeByTwo210"
}
