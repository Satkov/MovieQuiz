import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var resultAlertPresenter: AlertPresenterProtocol?
    private var StatisticService: StatisticServiceProtocol!

    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private var isEnable = true

    @IBOutlet weak private var questionNumberField: UILabel!
    @IBOutlet weak private var questionField: UILabel!
    @IBOutlet weak private var filmPosterImage: UIImageView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory

        let resultAlertPresenter = ResultAlertPresenter()
        resultAlertPresenter.setup(delegate: self)
        self.resultAlertPresenter = resultAlertPresenter

        questionFactory.requestNextQuestion()
        StatisticService = StatisticServiceImplementation()
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    private func show(quiz step: QuizStepViewModel) {
        filmPosterImage.image = step.image
        questionNumberField.text = step.questionNumber
        questionField.text = step.question
    }

    private func show(quiz result: QuizResultsViewModel) {
        StatisticService.store(
            correct: self.correctAnswers,
            total: self.questionsAmount
        )
        let completion = {
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        let message = StatisticService.getGamesStatistic(
            correct: self.correctAnswers,
            total: self.questionsAmount
        )
        let alertData = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion
        )
        resultAlertPresenter?.showAlert(alertData: alertData)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func showAnswerResult(isCorrect: Bool) {
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
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1

            self.questionFactory?.requestNextQuestion()
        }
        isEnable = true
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        if isEnable {
            guard let currentQuestion = currentQuestion else { return }
            showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
            isEnable = false
        }
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        if isEnable {
            guard let currentQuestion = currentQuestion else { return }
            showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
            isEnable = false
        }
    }
}
