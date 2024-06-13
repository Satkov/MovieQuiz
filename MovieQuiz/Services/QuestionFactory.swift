import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoadingProtocol
    private weak var delegate: QuestionFactoryDelegateProtocol?
    private var movies: [Movie] = []

    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegateProtocol?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    private func loadMovies(_ listOfFilms: ListsOfFilmsURL, dispatchGroup: DispatchGroup) {
        moviesLoader.loadMovies(listOfFilms) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
            switch result {
                case .success(let mostPopularMovies):
                    self.movies.append(contentsOf: mostPopularMovies)
                    dispatchGroup.leave()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func loadData() {
        let group = DispatchGroup()
        group.enter()
        loadMovies(ListsOfFilmsURL.mostPopularMoviesURL, dispatchGroup: group)
        group.enter()
        loadMovies(ListsOfFilmsURL.top250MovieURL, dispatchGroup: group)

        group.notify(queue: .main) {
            self.delegate?.didLoadDataFromServer()
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else { return }

            var imageData = Data()

            if let rating = movie.rating,
               let imageURL = movie.imageURL {
           do {
                imageData = try Data(contentsOf: imageURL)
            } catch {
                print("Failed to load image")
            }

                let rating = Float(rating) ?? 0
                let ratingForQuestion = Float.randomRatingNumber(rating: rating)
                let text = "Рейтинг этого фильма больше чем \(String(format: "%.1f", ratingForQuestion))?"
                let correctAnswer = rating > ratingForQuestion

                let question = QuizQuestion(image: imageData,
                                            text: text,
                                            correctAnswer: correctAnswer)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            } else { requestNextQuestion() }
        }
    }
}

//    private let questions: [QuizQuestion] = [
// QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
// QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
// QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
// QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
// QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
// QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
// QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
// QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
// QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
// QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
// ]
