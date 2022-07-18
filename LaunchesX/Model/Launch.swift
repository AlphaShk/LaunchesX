import Foundation

struct Launch: Codable {
    
    let links: Links
    let name: String // name can't be nil
    let details, date_local, date_precision: String?
}


// MARK: - Links
struct Links: Codable {
    let patch: Patch
    let flickr: Flickr
    let youtube_id: String?
}

// MARK: - Flickr
struct Flickr: Codable {
    let original: [String?]
}

// MARK: - Patch
struct Patch: Codable {
    let small, large: String?
}

