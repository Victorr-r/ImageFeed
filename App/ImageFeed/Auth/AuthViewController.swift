import UIKit
import OSLog
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
	func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
	
	// MARK: - Private Properties
	weak var delegate: AuthViewControllerDelegate?
	private let oauth2Service = OAuth2Service.shared
	private let storage = OAuth2TokenStorage.shared
	private let showWebViewSegueIdentifier = "ShowWebView"
	private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ImageFeed", category: "Auth")
	
	// MARK: - Overrides Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBlack
		configureBackButton()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showWebViewSegueIdentifier {
			guard let webViewViewController = segue.destination as? WebViewViewController else {
				assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
				return
			}
			
			let authHelper = AuthHelper()
			
			let webViewPresenter = WebViewPresenter(authHelper: authHelper)
			webViewViewController.presenter = webViewPresenter
			webViewPresenter.view = webViewViewController
			webViewViewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
	
	// MARK: - Private Methods
	private func configureBackButton() {
		navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
		navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		navigationItem.backBarButtonItem?.tintColor = .ypBlack
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
		vc.dismiss(animated: true) { [weak self] in
			guard let self else { return }
			
			UIBlockingProgressHUD.show()
			
			self.oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
				DispatchQueue.main.async {
					
					UIBlockingProgressHUD.dismiss()
					
					guard let self else { return }
					
					switch result {
					case .success(let token):
						self.storage.token = token
						self.delegate?.didAuthenticate(self)
						
					case .failure(let error):
						self.logger.error("OAuth2Service Error - \(error.localizedDescription)")
						self.showErrorAlert()
					}
				}
			}
		}
	}
	
	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		vc.dismiss(animated: true)
	}
}

