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
}

// MARK: - ProfileService
final class ProfileService {
	
	// MARK: - Properties
	static let shared = ProfileService()
	private(set) var profile: Profile?
	private init() {}
	
	private var task: URLSessionDataTask?
	private let urlSession = URLSession.shared
	
	// MARK: - Public Methods
	func fetchProfile(_ token: String, completion: @escaping(Result<Profile, Error>) -> Void) {
		task?.cancel()
		
		guard let request = makeProfileRequest(token: token) else {
			completion(.failure(URLError(.badURL)))
			return
		}
		
		let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
			DispatchQueue.main.async {
				guard let self else { return }
				self.task = nil
				if let error = error {
					completion(.failure(error))
					return
				}
				guard let data = data else {
					completion(.failure(NetworkError.urlSessionError))
					return
				}
				do {
					let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
					
					let profile = Profile(
						username: profileResult.username,
						name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces),
						loginName: "@\(profileResult.username)",
						bio: profileResult.bio)
					self.profile = profile
					completion(.success(profile))
				} catch {
					completion(.failure(NetworkError.decodingError(error)))
				}
			}
		}
		self.task = task
		task.resume()
	}
	
	// MARK: - Private Methods
	private func makeProfileRequest(token: String) -> URLRequest? {
		guard let url = URL(string: "https://api.unsplash.com/me") else {
			assertionFailure("Failed to create URL")
			return nil
		}
		var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
		
		request.httpMethod = "GET"
		request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		return request
	}
}
