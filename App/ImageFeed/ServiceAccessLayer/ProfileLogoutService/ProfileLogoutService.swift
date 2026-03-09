import Foundation
import WebKit

final class ProfileLogoutService {
	static let shared = ProfileLogoutService()
	
	private init() { }
	
	func logout() {
		cleanCookies()
		clearData()
	}
	
	private func cleanCookies() {
		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
			records.forEach { record in
				WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
			}
		}
	}
	
	private func clearData() {
		OAuth2TokenStorage.shared.token = nil
		
		ProfileService.shared.clear()
		ProfileImageService.shared.clear()
		ImagesListService.shared.clear()
	}
}

