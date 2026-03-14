import Foundation

// MARK: - Models
struct UserResult: Codable {
	let profileImage: ProfileImage
	
	struct ProfileImage: Codable {
		let small: String
	}
}

// MARK: - ProfileImageService
final class ProfileImageService {
	
	static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
	static let shared = ProfileImageService()
	private(set) var avatarURL: String?
	
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private let storage = OAuth2TokenStorage.shared
	
	private init() {}
	
	// MARK: - Public Methods
	func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
		task?.cancel()
		
		guard let token = storage.token else {
			completion(.failure(NetworkError.urlSessionError))
			return
		}
		
		guard let request = makeProfileImageRequest(username: username, token: token) else {
			completion(.failure(URLError(.badURL)))
			return
		}
		
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
			guard let self else { return }
			self.task = nil
			
			switch result {
			case .success(let userResult):
				let imageURL = userResult.profileImage.small
				self.avatarURL = imageURL
				
				completion(.success(imageURL))
				
				NotificationCenter.default.post(
					name: ProfileImageService.didChangeNotification,
					object: self,
					userInfo: ["URL": imageURL]
				)
				
			case .failure(let error):
				print("[ProfileImageService]: ImageError - \(error.localizedDescription)")
				completion(.failure(error))
			}
		}
		self.task = task
		task.resume()
	}
	
	//MARK: - Private Methods
	private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
		guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return nil }
		
		var request = URLRequest(url: url)
		request.httpMethod = HTTPMethod.get.rawValue
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return request
	}
	
	func clear() {
		avatarURL = nil
	}
}
