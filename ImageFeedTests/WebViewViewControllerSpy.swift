import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
	var presenter: WebViewPresenterProtocol?
	var loadCalled: Bool = false
	
	func load(request: URLRequest) {
		loadCalled = true
	}
	
	func setProgressValue(_ newValue: Float) {
		
	}
	
	func setProgressHidden(_ isHidden: Bool) {
		
	}
}
