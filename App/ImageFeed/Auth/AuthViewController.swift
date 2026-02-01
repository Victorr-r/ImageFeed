import UIKit

protocol AuthViewControllerDelegate: AnyObject {
	func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
	
	// MARK: - Private Properties
	weak var delegate: AuthViewControllerDelegate?
	private let oauth2Service = OAuth2Service.shared
	private let storage = OAuth2TokenStorage()
	private let showWebViewSegueIdentifier = "ShowWebView"
	
	// MARK: - Overrides Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		configureBackButton()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showWebViewSegueIdentifier {
			guard let webViewViewController = segue.destination as? WebViewViewController else {
				assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
				return
			}
			webViewViewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
	
	// MARK: - Private Methods
	private func configureBackButton() {
		navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
		navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
	}
	
	private func showErrorAlert() {
		let alert = UIAlertController(
			title: "Что-то пошло не так",
			message: "Не удалось войти в систему",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "ОК", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
		UIBlockingProgressHUD.show()
		
		oauth2Service.fetchOAuthToken(code: code) { [weak self, weak vc] result in
			guard let self = self else { return }
			UIBlockingProgressHUD.dismiss()
			
			switch result {
			case .success(let token):
				self.storage.token = token
				vc?.dismiss(animated: true) { [weak self] in
					guard let self = self else { return }
					self.delegate?.didAuthenticate(self)
				}
				
			case .failure(let error):
				print("[AuthViewController]: OAuth2 token request failed - \(error)")
				vc?.dismiss(animated: true) { [weak self] in
					guard let self = self else { return }
					self.showErrorAlert()
				}
			}
		}
	}
	
	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		vc.dismiss(animated: true)
	}
}
