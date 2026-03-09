@preconcurrency import Foundation

nonisolated struct OAuthTokenResponseBody: Codable {
	let accessToken: String
}

enum AuthServiceError: Error {
	case invalidRequest
}

final class OAuth2Service {
	
	// MARK: - Private Properties
	static let shared = OAuth2Service()
	private var task: URLSessionTask?
	private var lastCode: String?
	private let urlSession = URLSession.shared
	
	private init() {}
	
	// MARK: - Public Methods
	func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
		assert(Thread.isMainThread)
		
		if lastCode == code { return }
		
		task?.cancel()
		lastCode = code
		guard let request = makeOAuthTokenRequest(code: code) else {
			completion(.failure(AuthServiceError.invalidRequest))
			return
		}
		
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
			DispatchQueue.main.async {
				guard let self else { return }
				self.task = nil
				
				switch result {
				case .success(let responseBody):
					completion(.success(responseBody.accessToken))
					
				case .failure(let error):
					print("[OAuth2Service]: AuthServiceError - \(error.localizedDescription)")
					self.lastCode = nil
					completion(.failure(error))
				}
			}
		}
		self.task = task
		task.resume()
	}
	// MARK: - Private Methods
	
	private func makeOAuthTokenRequest(code: String) -> URLRequest? {
		guard var urlComponents = URLComponents(string: "https://unsplash.com") else {
			assertionFailure("Failed to create URLComponents")
			return nil
		}
		urlComponents.path = "/oauth/token"
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: Constants.accessKey),
			URLQueryItem(name: "client_secret", value: Constants.secretKey),
			URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
			URLQueryItem(name: "code", value: code),
			URLQueryItem(name: "grant_type", value: "authorization_code")
		]
		
		guard let url = urlComponents.url else {
			assertionFailure("Failed to create URL from components")
			return nil
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = HTTPMethod.post.rawValue
		
		return request
	}
}
