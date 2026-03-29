import UIKit
import Kingfisher

// MARK: - Protocols

protocol ProfilePresenterProtocol: AnyObject {
	var view: ProfileViewControllerProtocol? { get set }
	func viewDidLoad()
	func logOut()
}

protocol ProfileViewControllerProtocol: AnyObject {
	func updateProfileDetails(name: String, login: String, bio: String?)
	func updateAvatar(url: URL)
}

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
	
	// MARK: - Private Properties
	
	private var presenter: ProfilePresenterProtocol?
	
	private let avatarImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(resource: .profil)
		imageView.layer.cornerRadius = 35
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Екатерина Новикова"
		label.font = .systemFont(ofSize: 23, weight: .semibold)
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let loginNameLabel: UILabel = {
		let label = UILabel()
		label.text = "@ekaterina_nov"
		label.font = .systemFont(ofSize: 13, weight: .regular)
		label.textColor = .ypGray
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.text = "Hello, world!"
		label.font = .systemFont(ofSize: 13, weight: .regular)
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let logoutButton: UIButton = {
		let button = UIButton(type: .custom)
		let buttonImage = UIImage(named: "profil button")
		button.setImage(buttonImage, for: .normal)
		button.tintColor = .ypRed
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBlack
		
		setupHierarchy()
		setupLayout()
		setupActions()
		
		nameLabel.accessibilityIdentifier = "Name Label"
		loginNameLabel.accessibilityIdentifier = "Login Label"
		logoutButton.accessibilityIdentifier = "logout button"
		
		presenter?.viewDidLoad()
	}
	
	// MARK: - Public Methods
	
	func configure(_ presenter: ProfilePresenterProtocol) {
		self.presenter = presenter
		self.presenter?.view = self
	}
	
	// MARK: - ProfileViewControllerProtocol
	
	func updateProfileDetails(name: String, login: String, bio: String?) {
		nameLabel.text = name
		loginNameLabel.text = login
		descriptionLabel.text = bio
	}
	
	func updateAvatar(url: URL) {
		let processor = RoundCornerImageProcessor(cornerRadius: 35)
		avatarImageView.kf.indicatorType = .activity
		avatarImageView.kf.setImage(
			with: url,
			placeholder: UIImage(named: "profil"),
			options: [
				.processor(processor),
				.transition(.fade(0.5))
			]
		)
	}
	
	// MARK: - Private Methods
	
	private func setupHierarchy() {
		[avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
			view.addSubview($0)
		}
	}
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
			avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			avatarImageView.widthAnchor.constraint(equalToConstant: 70),
			avatarImageView.heightAnchor.constraint(equalToConstant: 70),
			
			logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
			logoutButton.widthAnchor.constraint(equalToConstant: 44),
			logoutButton.heightAnchor.constraint(equalToConstant: 44),
			
			nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
			nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
			nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			
			loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
			loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
			loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
			
			descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
			descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
		])
	}
	
	private func logout() {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
			return
		}
		window.rootViewController = SplashViewController()
		window.makeKeyAndVisible()
	}
	
	// MARK: - Actions
	
	private func setupActions() {
		logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
	}
	
	@objc private func didTapLogoutButton() {
		let alert = UIAlertController(
			title: "Пока, пока!",
			message: "Уверены, что хотите выйти?",
			preferredStyle: .alert
		)
		
		let yesAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
			guard let self else { return }
			self.presenter?.logOut()
			self.logout()
		}
		
		alert.addAction(yesAction)
		alert.addAction(UIAlertAction(title: "Нет", style: .default))
		present(alert, animated: true)
	}
}
