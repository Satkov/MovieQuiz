import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegateProtocol {
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var correctAnswers: Int = 0
    var isButtonsEnable = true
    private let presenter = MovieQuizPresenter()

    @IBOutlet weak private var questionNumberField: UILabel!
    @IBOutlet weak private var questionField: UILabel!
    @IBOutlet weak private var filmPosterImage: UIImageView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        let resultAlertPresenter = AlertPresenter()
        resultAlertPresenter.setup(delegate: self)
        self.alertPresenter = resultAlertPresenter
        filmPosterImage.contentMode = .scaleToFill
        showLoadingIndicator()
        questionFactory?.loadData()
        presenter.viewController = self
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alertData = AlertModel(
                        title: "Ошибка!",
                        message: message,
                        buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }

            presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(alertData: alertData)
    }

    func show(quiz step: QuizStepViewModel) {
        filmPosterImage.image = step.image
        questionNumberField.text = step.questionNumber
        questionField.text = step.question
        isButtonsEnable = true
    }

    func show(quiz result: QuizResultsViewModel) {
        statisticService.store(
            correct: self.correctAnswers,
            total: 10
        )
        let completion = {
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            self.showLoadingIndicator()
        }
        let message = statisticService.getGamesStatistic(
            correct: self.correctAnswers,
            total: 10
        )
        let alertData = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion
        )
        alertPresenter?.showAlert(alertData: alertData)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        filmPosterImage.layer.borderWidth = 8
        filmPosterImage.layer.cornerRadius = 20
        filmPosterImage.layer.borderColor = (isCorrect ? UIColor.ypGreen.cgColor: UIColor.ypRed.cgColor)
        if isCorrect {
            correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.filmPosterImage.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func showNextQuestionOrResults() {
        let currentQuestionIndex = presenter.getCurrentQuestionIndex()
        if currentQuestionIndex == 9 {
            let text = correctAnswers == 10 ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
            self.showLoadingIndicator()
        }
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
