import UIKit

final class MovieQuizViewController: UIViewController {
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol!
    private var presenter: MovieQuizPresenter!
    var isButtonsEnable = true

    @IBOutlet weak private var questionNumberField: UILabel!
    @IBOutlet weak private var questionField: UILabel!
    @IBOutlet weak private var filmPosterImage: UIImageView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        presenter = MovieQuizPresenter(viewController: self)
        let resultAlertPresenter = AlertPresenter()
        resultAlertPresenter.setup(delegate: self)
        self.alertPresenter = resultAlertPresenter
        filmPosterImage.contentMode = .scaleToFill
        showLoadingIndicator()
        presenter.viewController = self
        presenter.questionFactory?.loadData()
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        presenter.questionFactory?.requestNextQuestion()
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

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let alertData = AlertModel(
                        title: "Ошибка!",
                        message: message,
                        buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }

            presenter.restartGame()
            presenter.questionFactory?.loadData()
            presenter.questionFactory?.requestNextQuestion()
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
            correct: presenter.correctAnswers,
            total: 10
        )
        let completion = {
            self.presenter.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
            self.showLoadingIndicator()
        }
        let message = statisticService.getGamesStatistic(
            correct: presenter.correctAnswers,
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.filmPosterImage.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func showNextQuestionOrResults() {
        let currentQuestionIndex = presenter.getCurrentQuestionIndex()
        if currentQuestionIndex == 9 {
            let text = presenter.correctAnswers == 10 ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(presenter.correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            presenter.questionFactory?.requestNextQuestion()
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
