import Foundation

enum Constants {
	static let accessKey = "O5lhZPwLiwb9-uUgn0L5vYpjhL9hwv5NVbAI3Hli-uY"
	static let secretKey = "WNXnZEV5LmGwtqXv3uE__N8bmqau8mOiMsXjxqxiH1E"
	static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
	static let accessScope = "public+read_user+write_likes"
	static let defaultBaseURLString = "https://api.unsplash.com"
	static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
	static var standard: AuthConfiguration {
		return AuthConfiguration(accessKey: Constants.accessKey,
								 secretKey: Constants.secretKey,
								 redirectURI: Constants.redirectURI,
								 accessScope: Constants.accessScope,
								 authURLString: Constants.unsplashAuthorizeURLString,
								 defaultBaseURLString: Constants.defaultBaseURLString)
	}
}

struct AuthConfiguration {
	let accessKey: String
	let secretKey: String
	let redirectURI: String
	let accessScope: String
	let defaultBaseURLString: String
	let authURLString: String
	
	init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
		self.accessKey = accessKey
		self.secretKey = secretKey
		self.redirectURI = redirectURI
		self.accessScope = accessScope
		self.defaultBaseURLString = defaultBaseURLString
		self.authURLString = authURLString
	}
}
