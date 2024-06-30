import UIKit

final class MovieQuizPresenter {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
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
    
    func isLastQuestion() -> Bool {
        questionsAmount == currentQuestionIndex
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
            guard let currentQuestion = currentQuestion else { return }
            viewController.showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
            viewController.isButtonsEnable = false
        }
    }

    func noButtonClicked() {
        guard let viewController else { return }
        if viewController.isButtonsEnable {
            guard let currentQuestion = currentQuestion else { return }
            viewController.showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
            viewController.isButtonsEnable = false
        }
    }
}
