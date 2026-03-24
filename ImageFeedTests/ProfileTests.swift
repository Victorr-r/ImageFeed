import XCTest
@testable import ImageFeed
@MainActor

final class ProfileTests: XCTestCase {
	
	func testViewControllerCallsViewDidLoad() {
		let viewController = ProfileViewController()
		let presenterSpy = ProfilePresenterSpy()
		
		viewController.configure(presenterSpy)
		
		_ = viewController.view
		
		XCTAssertTrue(presenterSpy.viewDidLoadCalled)
	}
}

