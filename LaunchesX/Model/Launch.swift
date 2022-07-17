import Foundation

struct Launch: Codable {
    let links: Links
    let details: String?
    let name: String
    let id: String
    let date_local: String?
    let date_precision: String?

}


// MARK: - Links
struct Links: Codable {
    let patch: Patch
    let flickr: Flickr
    let webcast: String?
    let youtube_id: String?
    let article: String?
    let wikipedia: String?
}

// MARK: - Flickr
struct Flickr: Codable {
    let original: [String?]
}

// MARK: - Patch
struct Patch: Codable {
    let small, large: String?
}

