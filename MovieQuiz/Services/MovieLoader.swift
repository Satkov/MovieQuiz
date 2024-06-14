import Foundation

enum ListsOfFilmsURL: String {
    case top250MovieURL = "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf"
    case mostPopularMoviesURL = "https://tv-api.com/en/API/MostPopularMovies/k_zcuw1ytf"
}

struct MoviesLoader: MoviesLoadingProtocol {
    // MARK: - NetworkClient
    private let networkClient: NetworkRoutingProtocol
    
    init(networkClient: NetworkRoutingProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    // MARK: - URL
    private func getURL(_ listsOfFilmsURL: ListsOfFilmsURL) -> URL {
        guard let url = URL(string: listsOfFilmsURL.rawValue) else {
            preconditionFailure("Unable to construct \(listsOfFilmsURL.rawValue)")
        }
        return url
    }

    func loadMovies(_ listOfFilms: ListsOfFilmsURL, handler: @escaping (Result<[Movie], Error>) -> Void) {
        networkClient.fetch(url: getURL(listOfFilms)) { result in
            switch result {
            case .success(let data):
                do {
                    let movies = try JSONDecoder().decode(Movies.self, from: data)
                    handler(.success(movies.items))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
                return
            }
        }
    }
}
