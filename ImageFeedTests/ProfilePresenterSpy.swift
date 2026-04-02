import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
	weak var view: ProfileViewControllerProtocol?
	var viewDidLoadCalled: Bool = false
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func logOut() {
	}
}
