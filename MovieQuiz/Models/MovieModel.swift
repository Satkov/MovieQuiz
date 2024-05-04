import UIKit

struct TopModel: Decodable {
    let items: [MovieModel]
}

struct MovieModel: Codable {
    let id: String
    let rank: Int
    let title: String
    let fullTitle: String
    let year: Int
    let image: String
    let crew: String
    let imDbRating: Double
    let imDbRatingCount: Int
    
    private enum ParseError: Error {
        case rankFailure
        case yearFailure
        case IMDbRatingFailure
        case IMDbRatingCountFailure
    }
    
    private enum CodingKeys: CodingKey {
        case id
        case rank
        case title
        case fullTitle
        case year
        case image
        case crew
        case imDbRating
        case imDbRatingCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rank = try container.decode(String.self, forKey: .rank)
        guard let rankValue = Int(rank) else {
            throw ParseError.rankFailure
        }
        let year = try container.decode(String.self, forKey: .year)
        guard let yearValue = Int(year) else {
            throw ParseError.yearFailure
        }
        let imDbRating = try container.decode(String.self, forKey: .imDbRating)
        guard let imDbRatingValue = Double(imDbRating) else {
            throw ParseError.IMDbRatingFailure
        }
        let imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
        guard let imDbRatingCountValue = Int(imDbRatingCount) else {
            throw ParseError.IMDbRatingFailure
        }
        
        self.id = try container.decode(String.self, forKey: .id)
        self.rank = rankValue
        self.title = try container.decode(String.self, forKey: .title)
        self.fullTitle = try container.decode(String.self, forKey: .fullTitle)
        self.year = yearValue
        self.image = try container.decode(String.self, forKey: .image)
        self.crew = try container.decode(String.self, forKey: .crew)
        self.imDbRating = imDbRatingValue
        self.imDbRatingCount = imDbRatingCountValue
    }
}

func getMovies(from jsonString: String) -> [MovieModel]? {

    var movies: [MovieModel]? = nil
    do {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let top = try JSONDecoder().decode(TopModel.self, from: data)
        movies = top.items
    } catch {
        print("Failed to parse: \(jsonString)")
    }
    
    return movies
}
