import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
	
	// MARK: - Private Properties
	private var viewController: ImageListViewController!
	private var presenterSpy: ImagesListPresenterSpy!
	
	// MARK: - Setup
	override func setUp() async throws {
		try await super.setUp()
		
		let controller = try await MainActor.run {
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as? ImageListViewController
			
			return try XCTUnwrap(vc, "Не удалось инициализировать ImageListViewController из Storyboard")
		}
		
		let spy = await MainActor.run { ImagesListPresenterSpy() }
		
		await MainActor.run {
			controller.configure(spy)
			spy.view = controller
		}
		
		self.viewController = controller
		self.presenterSpy = spy
	}
	
	override func tearDown() {
		viewController = nil
		presenterSpy = nil
		super.tearDown()
	}
	
	// MARK: - Tests
	
	@MainActor
	func testViewDidLoad_callsPresenterViewDidLoad() {
		// Given: всё окружение настроено в setUp()
		
		// When: обращаемся к view, что триггерит viewDidLoad контроллера
		_ = viewController.view
		
		// Then: проверяем, что контроллер передал вызов в презентер
		XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Метод viewDidLoad в презентере должен быть вызван")
	}
}
