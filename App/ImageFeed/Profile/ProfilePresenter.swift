import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
	
	// MARK: - Public Properties
	weak var view: ProfileViewControllerProtocol?
	
	// MARK: - Private Properties
	private var profileImageServiceObserver: NSObjectProtocol?
	private let profileService = ProfileService.shared
	private let profileImageService = ProfileImageService.shared
	
	// MARK: - Initializer
	deinit {
		if let observer = profileImageServiceObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	// MARK: - ProfilePresenterProtocol
	func viewDidLoad() {
		if let profile = profileService.profile {
			view?.updateProfileDetails(
				name: profile.name,
				login: profile.loginName,
				bio: profile.bio
			)
		}
		setupAvatarObserver()
		updateAvatar()
	}
	
	func logOut() {
		ProfileLogoutService.shared.logout()
	}
	
	// MARK: - Private Methods
	
	
	private func setupAvatarObserver() {
		profileImageServiceObserver = NotificationCenter.default.addObserver(
			forName: ProfileImageService.didChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			guard let self = self else { return }
			self.updateAvatar()
		}
	}
	
	private func updateAvatar() {
		guard
			let profileImageURL = profileImageService.avatarURL,
			let url = URL(string: profileImageURL)
		else { return }
		
		view?.updateAvatar(url: url)
	}
}
