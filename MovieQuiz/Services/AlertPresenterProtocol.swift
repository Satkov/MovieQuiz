import UIKit

protocol AlertPresenterProtocol {
    func setup(delegate: UIViewController) -> Void
    func showAlert(alertData: AlertModel) -> Void
}
