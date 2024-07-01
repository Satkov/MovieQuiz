import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet weak private var questionNumberField: UILabel!
    @IBOutlet weak private var questionField: UILabel!
    @IBOutlet weak private var filmPosterImage: UIImageView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    var isButtonsEnable = true

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let resultAlertPresenter = AlertPresenter()
        self.alertPresenter = resultAlertPresenter
        resultAlertPresenter.setup(delegate: self)
        
        presenter = MovieQuizPresenter(viewController: self)
        
        filmPosterImage.contentMode = .scaleToFill
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.answerButtonClicked(answerIsYes: true)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.answerButtonClicked(answerIsYes: false)
    }
    
    // MARK: - Private functions

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

    func hideIndicatorsAfterLoading() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        unHighlightImageBoarder()
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        filmPosterImage.layer.borderWidth = 8
        filmPosterImage.layer.cornerRadius = 20
        filmPosterImage.layer.borderColor = (isCorrect ? UIColor.ypGreen.cgColor: UIColor.ypRed.cgColor)
    }
    
    func unHighlightImageBoarder() {
        filmPosterImage.layer.borderColor = UIColor.clear.cgColor
    }

    func showNetworkError(message: String) {
        hideIndicatorsAfterLoading()

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
        let completion = {
            self.presenter.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
            self.showLoadingIndicator()
        }
        
        let message = presenter.makeResultMessage()
        
        let alertData = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion
        )
        
        alertPresenter?.showAlert(alertData: alertData)
    }
}
