import Foundation

// MARK: - Models
struct ProfileResult: Codable {
	let username: String
	let firstName: String?
	let lastName: String?
	let bio: String?
	
	private enum CodingKeys: String, CodingKey {
		case username
		case firstName = "first_name"
		case lastName = "last_name"
		case bio
	}
}

struct Profile {
	let username: String
	let name: String
	let loginName: String
	let bio: String?
	
	init(from result: ProfileResult) {
		self.username = result.username
		self.loginName = "@\(result.username)"
		self.bio = result.bio
		
		let components = [result.firstName, result.lastName].compactMap { $0 }
		self.name = components.joined(separator: " ")
	}
}

// MARK: - ProfileService
final class ProfileService {
	
	// MARK: - Properties
	static let shared = ProfileService()
	private(set) var profile: Profile?
	private var task: URLSessionTask?
	private let urlSession = URLSession.shared
	
	private init() {}
	
	// MARK: - Public Methods
	func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
		task?.cancel()
		
		guard let request = makeProfileRequest(token: token) else {
			completion(.failure(NetworkError.invalidRequest))
			return
		}
		
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
		guard let self else { return }
			self.task = nil
				
				switch result {
							case .success(let profileResult):
								let profile = Profile(from: profileResult)
								self.profile = profile
								
								completion(.success(profile))
								
							case .failure(let error):
					print("[ProfileService]: ProfileError - \(error.localizedDescription)")
								completion(.failure(error))
							}
						}
		
		self.task = task
		task.resume()
	}
	
	// MARK: - Private Methods
	private func makeProfileRequest(token: String) -> URLRequest? {
		guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
		var request = URLRequest(url: url)
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		return request
	}
}
