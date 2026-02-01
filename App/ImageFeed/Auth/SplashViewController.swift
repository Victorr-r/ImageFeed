import UIKit

final class SplashViewController: UIViewController {
	
	// MARK: - Private Properties
	private let storage = OAuth2TokenStorage()
	private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
	
	// MARK: - Overrides Methods
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if storage.token != nil {
			switchToTabBarController()
		} else {
			performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showAuthenticationScreenSegueIdentifier {
			guard
				let navigationController = segue.destination as? UINavigationController,
				let viewController = navigationController.viewControllers.first as? AuthViewController
			else {
				assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
				return
			}
			viewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
	
	// MARK: - Private Methods
	private func switchToTabBarController() {
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

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
	func didAuthenticate(_ vc: AuthViewController) {
		switchToTabBarController()
	}
}

