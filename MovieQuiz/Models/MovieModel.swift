import UIKit

struct Movies: Codable {
    let items: [Movie]
    let errorMessage: String
}

struct Movie: Codable {
    let title: String
    let rating: String?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case title
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
