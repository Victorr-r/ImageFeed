import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
	
	// MARK: - Private Properties
	private var viewController: ProfileViewController!
	private var presenterSpy: ProfilePresenterSpy!
	
	// MARK: - Setup
	override func setUp() async throws {
		try await super.setUp()
		
		let spy = await MainActor.run { ProfilePresenterSpy() }
		let controller = await MainActor.run { ProfileViewController() }
		
		await MainActor.run {
			controller.configure(spy)
			spy.view = controller
		}
		
		self.presenterSpy = spy
		self.viewController = controller
	}
	
	override func tearDown() {
		viewController = nil
		presenterSpy = nil
		super.tearDown()
	}
	
	// MARK: - Tests
	
	@MainActor
	func testViewControllerCallsViewDidLoad() {
		// Given: всё настроено в setUp
		
		// When
		_ = viewController.view // Триггерим вызов viewDidLoad
		
		// Then
		XCTAssertTrue(presenterSpy.viewDidLoadCalled)
	}
}

