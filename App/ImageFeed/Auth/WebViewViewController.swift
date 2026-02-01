import UIKit
import WebKit

// MARK: - WebViewViewControllerDelegate Protocol
protocol WebViewViewControllerDelegate: AnyObject {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
	func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
	
	// MARK: - IB Outlets
	@IBOutlet private var webView: WKWebView!
	@IBOutlet private var progressView: UIProgressView!
	
	// MARK: - Public Properties
	weak var delegate: WebViewViewControllerDelegate?
	
	// MARK: - Overrides Methods
	override func viewDidLoad() {
		super.viewDidLoad()
		loadAuthView()
		webView.navigationDelegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		webView.addObserver(
			self,
			forKeyPath: #keyPath(WKWebView.estimatedProgress),
			options: .new,
			context: nil
		)
		updateProgress()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
	}
	
	override func observeValue(
		forKeyPath keyPath: String?,
		of object: Any?,
		change: [NSKeyValueChangeKey : Any]?,
		context: UnsafeMutableRawPointer?
	) {
		if keyPath == #keyPath(WKWebView.estimatedProgress) {
			updateProgress()
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	private func updateProgress() {
		progressView.progress = Float(webView.estimatedProgress)
		progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
	}
	
	// MARK: - Private Methods
	private func loadAuthView() {
		guard var urlComponents = URLComponents(string: "https://unsplash.com") else { return }
		
		urlComponents.path = "/oauth/authorize"
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: Constants.accessKey),
			URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "scope", value: Constants.accessScope)
		]
		
		guard let url = urlComponents.url else { return }
		let request = URLRequest(url: url)
		webView.load(request)
		updateProgress()
	}
}


// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
	func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction,
		decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
	) {
		if let code = code(from: navigationAction) {
			delegate?.webViewViewController(self, didAuthenticateWithCode: code)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
	
	private func code(from navigationAction: WKNavigationAction) -> String? {
		if let url = navigationAction.request.url,
		   let urlComponents = URLComponents(string: url.absoluteString),
		   let items = urlComponents.queryItems,
		   let codeItem = items.first(where: { $0.name == "code" }) {
			return codeItem.value
		}
		return nil
	}
}
