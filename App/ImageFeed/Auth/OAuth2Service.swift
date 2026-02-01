import Foundation

final class OAuth2Service {
	
	// MARK: - Private Properties
	static let shared = OAuth2Service()
	private let urlSession = URLSession.shared
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
		let task = urlSession.data(for: request) { result in
			DispatchQueue.main.async {
				switch result {
				case .success(let data):
					do {
						let decoder = JSONDecoder()
						let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
						completion(.success(responseBody.accessToken))
					} catch {
						print("[OAuth2Service]: Decoding error - \(error.localizedDescription)")
						completion(.failure(NetworkError.decodingError(error)))
					}
				case .failure(let error):
					print("[OAuth2Service]: Network error - \(error.localizedDescription)")
					completion(.failure(error))
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
		request.httpMethod = "POST"
		
		return request
	}
}
