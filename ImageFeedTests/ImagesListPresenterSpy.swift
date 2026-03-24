import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
	var view: ImagesListViewControllerProtocol?
	var photos: [Photo] = []
	
	var viewDidLoadCalled = false
	var fetchPhotosCalled = false

	func viewDidLoad() {
		viewDidLoadCalled = true
	}

	func fetchPhotosNextPage() {
		fetchPhotosCalled = true
	}

	func handleLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {}

	func getCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
		return 100
	}
}
