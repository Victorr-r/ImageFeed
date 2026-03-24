import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
	
	@MainActor
	func testViewControllerCallsViewDidLoad() {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		guard let viewController = storyboard.instantiateViewController(
			withIdentifier: "ImagesListViewController"
		) as? ImageListViewController else {
			XCTFail("Could not instantiate ImageListViewController")
			return
		}
		
		let presenterSpy = ImagesListPresenterSpy()
		viewController.configure(presenterSpy)
		
		_ = viewController.view
		
		XCTAssertTrue(presenterSpy.viewDidLoadCalled)
	}
}
