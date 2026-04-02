import XCTest
@testable import ImageFeed

@MainActor
final class WebViewTests: XCTestCase {
	
	// MARK: - Properties
	private var presenter: WebViewPresenter!
	private var viewControllerSpy: WebViewViewControllerSpy!
	private var authHelper: AuthHelperProtocol!
	
	// MARK: - Lifecycle
	
	override func setUp() {
		super.setUp()
		
		// Given
		let configuration = Constants.standard
		let helper = AuthHelper(configuration: configuration)
		let webPresenter = WebViewPresenter(authHelper: helper)
		let spy = WebViewViewControllerSpy()
		
		webPresenter.view = spy
		spy.presenter = webPresenter
		
		// Сохраняем в свойства класса
		self.authHelper = helper
		self.presenter = webPresenter
		self.viewControllerSpy = spy
	}
	
	override func tearDown() {
		presenter = nil
		viewControllerSpy = nil
		authHelper = nil
		super.tearDown()
	}
	
	// MARK: - Tests
	
	func testViewControllerCallsViewDidLoad() {
		// Given
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let viewController = storyboard.instantiateViewController(
			withIdentifier: "WebViewViewController"
		) as! WebViewViewController
		
		let presenterSpy = WebViewPresenterSpy()
		viewController.presenter = presenterSpy
		presenterSpy.view = viewController
		
		// When
		_ = viewController.view
		
		// Then
		XCTAssertTrue(presenterSpy.viewDidLoadCalled)
	}
	
	func testPresenterCallsLoadRequest() {
		// Given: setup уже выполнен в setUp()
		
		// When
		presenter.viewDidLoad()
		
		// Then
		XCTAssertTrue(viewControllerSpy.loadCalled)
	}
	
	func testProgressVisibleWhenLessThanOne() {
		// Given
		let progress: Float = 0.6
		
		// When
		let shouldHide = presenter.shouldHideProgress(for: progress)
		
		// Then
		XCTAssertFalse(shouldHide)
	}
	
	func testProgressHiddenWhenOne() {
		// Given
		let progress: Float = 1.0
		
		// When
		let shouldHide = presenter.shouldHideProgress(for: progress)
		
		// Then
		XCTAssertTrue(shouldHide)
	}
	
	func testAuthHelperAuthURL() throws {
		// Given
		let configuration = Constants.standard
		
		// When
		let url = try XCTUnwrap(authHelper.authURL())
		let urlString = url.absoluteString
		
		// Then
		XCTAssertTrue(urlString.contains(configuration.authURLString))
		XCTAssertTrue(urlString.contains(configuration.accessKey))
		XCTAssertTrue(urlString.contains(configuration.redirectURI))
		XCTAssertTrue(urlString.contains("code"))
		XCTAssertTrue(urlString.contains(configuration.accessScope))
	}
	
	func testCodeFromURL() {
		// Given
		var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
		components.queryItems = [URLQueryItem(name: "code", value: "test code")]
		let url = components.url!
		
		// When
		let code = authHelper.code(from: url)
		
		// Then
		XCTAssertEqual(code, "test code")
	}
}
