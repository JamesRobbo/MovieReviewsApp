import Foundation

// MARK: - Critics
struct Critics: Codable {
    let status, copyright: String?
    let numResults: Int?
    let hasMore: Bool?
    let results: [Critic]?

    enum CodingKeys: String, CodingKey {
        case status, copyright
        case hasMore = "has_more"
        case numResults = "num_results"
        case results
    }
}

// MARK: - Critic
struct Critic: Codable {
    let displayName, sortName: String?
    let status: Status?
    let bio, seoName: String?
    let multimedia: CriticMultimedia?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case sortName = "sort_name"
        case status, bio
        case seoName = "seo_name"
        case multimedia
    }
}

// MARK: - CriticMultimedia
struct CriticMultimedia: Codable {
    let resource: Resource?
}

// MARK: - Resource
struct Resource: Codable {
    let type: String?
    let src: String?
    let height, width: Int?
    let credit: String?
}

enum Status: String, Codable {
    case empty = ""
    case fullTime = "full-time"
    case partTime = "part-time"
}
