import UIKit
import Kingfisher

final class SplashViewController: UIViewController {
	
	// MARK: - Private Properties
	private let storage = OAuth2TokenStorage.shared
	private let profileService = ProfileService.shared
	private var isStartedAuth = false
	
	private let splashImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(resource: .splashScreenLogo)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBlack
		setupUI()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if let token = storage.token {
			fetchProfile(token)
		} else {
			if !isStartedAuth {
				isStartedAuth = true
				showAuthenticationScreen()
			}
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	// MARK: - UI Setup
	private func setupUI() {
		view.addSubview(splashImageView)
		
		NSLayoutConstraint.activate([
			splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			splashImageView.widthAnchor.constraint(equalToConstant: 75),
				  splashImageView.heightAnchor.constraint(equalToConstant: 78)
		])
	}
	
	private func showAuthenticationScreen() {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		
		guard let authViewController = storyboard.instantiateViewController(
			withIdentifier: "AuthViewController"
		) as? AuthViewController else {
			assertionFailure("Failed to instantiate AuthViewController")
			return
		}
		
		authViewController.delegate = self
		authViewController.modalPresentationStyle = .fullScreen
		present(authViewController, animated: true)
	}
}
// MARK: - Navigation Logic
extension SplashViewController {
	func switchToTabBarController() {
		guard let window = UIApplication.shared.connectedScenes
			.compactMap({ $0 as? UIWindowScene })
			.flatMap({ $0.windows })
			.first(where: { $0.isKeyWindow })
		else {
			assertionFailure("Invalid Configuration")
			return
		}
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
		window.rootViewController = tabBarController
	}
}

// MARK: - Business Logic
private extension SplashViewController {
	func fetchProfile(_ token: String) {
		UIBlockingProgressHUD.show()
		
		profileService.fetchProfile(token) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success(let profile):
				ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
				UIBlockingProgressHUD.dismiss()
				self.switchToTabBarController()
				
			case .failure(let error):
				UIBlockingProgressHUD.dismiss()
				print("[SplashViewController]: ProfileService Error - \(error.localizedDescription)")
				self.showErrorAlert()
				
				self.isStartedAuth = false
			}
		}
	}
	
	func showErrorAlert() {
		let alert = UIAlertController(
			title: "Что-то пошло не так",
			message: "Не удалось войти в систему",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "Ок", style: .default))
		present(alert, animated: true)
	}
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
	func didAuthenticate(_ vc: AuthViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self, let token = self.storage.token else { return }
			self.fetchProfile(token)
		}
	}
}
