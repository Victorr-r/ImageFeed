import Foundation

// MARK: - WebViewPresenter Protocol
public protocol WebViewPresenterProtocol{
	
	var view: WebViewViewControllerProtocol? { get set }
	func viewDidLoad()
	func didUpdateProgressValue(_ newValue: Double)
	func code(from url: URL) -> String?
	
}

final class WebViewPresenter: WebViewPresenterProtocol {
	
	// MARK: - Public Properties
	weak var view: WebViewViewControllerProtocol?
	
	
	// MARK: - Private Properties
	private let authHelper: AuthHelperProtocol
	
	init(authHelper: AuthHelperProtocol) {
		self.authHelper = authHelper
	}
	
	// MARK: - Public Methods
	func viewDidLoad() {
		guard let request = authHelper.authRequest() else { return }
		view?.load(request: request)
		didUpdateProgressValue(0)
	}
	
	func didUpdateProgressValue(_ newValue: Double) {
		let newProgressValue = Float(newValue)
		view?.setProgressValue(newProgressValue)
		
		let shouldHideProgress = shouldHideProgress(for: newProgressValue)
		view?.setProgressHidden(shouldHideProgress)
	}
	
	func shouldHideProgress(for value: Float) -> Bool {
		abs(value - 1.0) <= 0.0001
	}
	
	func code(from url: URL) -> String? {
		authHelper.code(from: url)
	}
}
