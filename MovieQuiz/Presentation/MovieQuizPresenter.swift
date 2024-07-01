import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegateProtocol {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol!
    
    weak var viewController: MovieQuizViewControllerProtocol?
    
    var isButtonsEnable = true
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
            self.viewController = viewController
            viewController.showLoadingIndicator()
        
            statisticService = StatisticService()
        
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
        }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideIndicatorsAfterLoading()
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func answerButtonClicked(answerIsYes: Bool) {
        guard let viewController else { return }
        if isButtonsEnable {
            didAnswer(isYes: answerIsYes)
        }
    }

    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
        isButtonsEnable = false
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        countCorrectAnswers(isCorrect: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }

    func countCorrectAnswers(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }

    private func proceedToNextQuestionOrResults() {
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
        
        isButtonsEnable = true
    }
    
    func getCurrentQuestionIndex() -> Int {
        currentQuestionIndex
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func makeResultMessage() -> String {
        storeGameResults()
        let message = getGamesStatistic()
        return message
    }
    
    private func storeGameResults() {
        statisticService.store(
            correct: correctAnswers,
            total: 10
        )
    }
    
    private func getGamesStatistic() -> String {
        let score = "Ваш результат: \(correctAnswers)/10"
        let gameCount = "Количество сыграных квизов: \(statisticService.gamesCount)"
        let record = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%"
        return  [score, gameCount, record, averageAccuracy].joined(separator: "\n")
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func isLastQuestion() -> Bool {
        questionsAmount == currentQuestionIndex
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
}
