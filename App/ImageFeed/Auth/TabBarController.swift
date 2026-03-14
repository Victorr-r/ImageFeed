import UIKit

final class TabBarController: UITabBarController {
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureAppearance()
		
		configureViewControllers()
	}
	
	// MARK: - Private Methods
	private func configureAppearance() {
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = .ypBlack
		
		tabBar.standardAppearance = appearance
		tabBar.scrollEdgeAppearance = appearance
	}
	
	private func configureViewControllers() {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
		let imagesListViewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		)
		
		let profileViewController = ProfileViewController()
		profileViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage(named: "tab_profile_active"),
			selectedImage: nil
		)
		
		self.viewControllers = [imagesListViewController, profileViewController]
	}
}
