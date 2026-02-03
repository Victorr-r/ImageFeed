import Foundation

enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
}


final class OAuth2Service {
	
	// MARK: - Private Properties
	static let shared = OAuth2Service()
	private let urlSession = URLSession.shared
	private let decoder = JSONDecoder()
	private init() {}
	
	private struct OAuthTokenResponseBody: Codable {
		let accessToken: String
		
		enum CodingKeys: String, CodingKey {
			case accessToken = "access_token"
		}
	}
	
	// MARK: - Public Methods
	
	func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
		guard let request = makeOAuthTokenRequest(code: code) else {
			completion(.failure(NetworkError.invalidRequest))
			return
		}
		let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
			DispatchQueue.main.async {
				guard let self = self else { return } // Захватываем self для обращения к decoder
				
				if let error = error {
					print("[OAuth2Service]: Network error - \(error.localizedDescription)")
					completion(.failure(error))
					return
				}
				
				guard let data = data else { return }
				
				do {
					
					let responseBody = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
					completion(.success(responseBody.accessToken))
				} catch {
					print("[OAuth2Service]: Decoding error - \(error.localizedDescription)")
					completion(.failure(NetworkError.decodingError(error)))
				}
			}
		}
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
