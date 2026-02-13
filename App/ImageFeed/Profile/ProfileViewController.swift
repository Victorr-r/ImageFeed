import UIKit

final class ProfileViewController: UIViewController {
	
	private let profileService = ProfileService.shared
	private let storage = OAuth2TokenStorage()
	
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
		
		if let profile = ProfileService.shared.profile {
			updateProfileDetails(profile: profile)
		}
	}
	
	// MARK: - Private Methods
	private func updateProfileDetails(profile: Profile) {
		nameLabel.text = profile.name
		loginNameLabel.text = profile.loginName
		descriptionLabel.text = profile.bio
	}
	
	private func setupHierarchy() {
		
		view.addSubview(avatarImageView)
		view.addSubview(nameLabel)
		view.addSubview(loginNameLabel)
		view.addSubview(descriptionLabel)
		view.addSubview(logoutButton)
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
	
	private func setupActions() {
		logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
	}
	
	@objc private func didTapLogoutButton() {
		print("Нажата кнопка выхода")
	}
}
