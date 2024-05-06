import UIKit

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func setup(delegate: QuestionFactoryDelegate)
}
