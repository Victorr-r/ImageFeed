@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
	func testFetchPhotos() {
		OAuth2TokenStorage.shared.token = "AO_ke6dsdpwlTF8Wx6emnajaZdu_ohSrhTLqhLsG5J4"
		let service = ImagesListService.shared
			
			let expectation = self.expectation(description: "Wait for Notification")
			let observer = NotificationCenter.default.addObserver(
				forName: ImagesListService.didChangeNotification,
				object: nil,
				queue: .main) { _ in
					expectation.fulfill()
				}
			
			wait(for: [expectation], timeout: 10)
			
		NotificationCenter.default.removeObserver(observer)
		
			XCTAssertEqual(service.photos.count, 10)
		}
	}
