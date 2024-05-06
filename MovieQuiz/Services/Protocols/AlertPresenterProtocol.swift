import UIKit

protocol AlertPresenterProtocol {
    func setup(delegate: UIViewController)
    func showAlert(alertData: AlertModel)
}
