import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegateProtocol {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    
    weak var viewController: MovieQuizViewController?

    
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    private func showNextQuestionOrResults() {
        let currentQuestionIndex = getCurrentQuestionIndex()
        if currentQuestionIndex == 9 {
            let text = correctAnswers == 10 ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            viewController?.showLoadingIndicator()
        }
    }

    func isLastQuestion() -> Bool {
        questionsAmount == currentQuestionIndex
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func getCurrentQuestionIndex() -> Int {
        currentQuestionIndex
    }

    func yesButtonClicked() {
        guard let viewController else { return }
        if viewController.isButtonsEnable {
            didAnswer(isYes: true)
        }
    }

    func noButtonClicked() {
        guard let viewController else { return }
        if viewController.isButtonsEnable {
            didAnswer(isYes: false)
        }
    }

    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
        viewController?.isButtonsEnable = false
    }

    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
}
