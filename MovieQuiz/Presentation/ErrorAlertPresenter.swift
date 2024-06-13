import UIKit

final class ErrorAlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?

    func setup(delegate: UIViewController) {
        self.delegate = delegate
    }

    func createAlert(_ alertData: AlertModel) -> UIAlertController {
        let alert = UIAlertController(
            title: alertData.title,
            message: alertData.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: alertData.buttonText, style: .default) { _ in
            alertData.completion()
        }

        alert.addAction(action)
        return alert
    }

    func showAlert(alertData: AlertModel) {
        let alert = createAlert(alertData)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
