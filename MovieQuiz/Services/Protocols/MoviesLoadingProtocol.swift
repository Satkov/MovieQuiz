import Foundation

protocol MoviesLoadingProtocol {
    func loadMovies(_ listOfFilms: ListsOfFilmsURL, handler: @escaping (Result<[Movie], Error>) -> Void)
}
