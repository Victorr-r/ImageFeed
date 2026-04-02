import XCTest

final class Image_FeedUITests: XCTestCase {
	private var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments.append("testMode")
		app.launch()
	}
	
	func testAuth() throws {
		// Given
		let authButton = app.buttons["Authenticate"]
		XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Кнопка не найдена!")
		
		// When
		authButton.tap()
		
		let webView = app.webViews["UnsplashWebView"]
		XCTAssertTrue(webView.waitForExistence(timeout: 15), "WebView не появилось")
		
		let loginTextField = webView.descendants(matching: .textField).firstMatch
		XCTAssertTrue(loginTextField.waitForExistence(timeout: 20), "Поле логина не появилось")
		loginTextField.tap()
		loginTextField.typeText("viktorrr398@gmail.com")
		
		if app.toolbars.buttons["Done"].exists {
			app.toolbars.buttons["Done"].tap()
		} else {
			webView.swipeUp()
		}
		
		let passwordTextField = webView.descendants(matching: .secureTextField).element
		XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
		passwordTextField.tap()
		sleep(1)
		
		UIPasteboard.general.string = "xypVy2-gifdob-pyjsek"
		passwordTextField.doubleTap()
		app.menuItems["Paste"].tap()
		if app.toolbars.buttons["Done"].exists {
			app.toolbars.buttons["Done"].tap()
		} else {
			webView.swipeUp()
		}
		
		sleep(2)
		
		webView.buttons["Login"].tap()
		
		// Then
		let tablesQuery = app.tables
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		
		XCTAssertTrue(cell.waitForExistence(timeout: 30), "Лента не загрузилась. Возможно, ошибка в запросе профиля.")
	}
	
	func testFeed() throws {
		// Given
		let tablesQuery = app.tables
		let firstCell = tablesQuery.cells.element(boundBy: 0)
		XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Лента не загрузилась")
		
		// When
		tablesQuery.element.swipeUp()
		sleep(2)
		
		let cellToLike = tablesQuery.cells.element(boundBy: 0)
		let likeButtonOff = cellToLike.buttons["like button off"]
		XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 10), "Кнопка лайка (off) не найдена")
		likeButtonOff.tap()
		
		// Then
		let likeButtonOn = cellToLike.buttons["like button on"]
		XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 10), "Лайк не включился")
		
		// When (продолжаем действие — переход на экран и обратно)
		likeButtonOn.tap()
		XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 10), "Лайк не выключился")
		
		cellToLike.tap()
		
		let fullImage = app.images.element
		XCTAssertTrue(fullImage.waitForExistence(timeout: 20), "Экран Single Image не открылся")
		
		fullImage.pinch(withScale: 3, velocity: 1)
		
		fullImage.pinch(withScale: 0.5, velocity: -1)
		
		let navBackButton = app.buttons["nav back button white"].firstMatch
		XCTAssertTrue(navBackButton.waitForExistence(timeout: 10), "Кнопка назад не найдена")
		navBackButton.tap()
		
		// Then
		XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
	}
	
	func testProfile() throws {
		// Given
		sleep(5)
		let profileTab = app.tabBars.buttons.element(boundBy: 1)
		XCTAssertTrue(profileTab.waitForExistence(timeout: 10))
		
		// When (Действие: переходим в профиль)
		profileTab.tap()
		
		// Then (Проверка: сверяем имя и логин)
		let nameLabel = app.staticTexts["Name Label"]
		let loginLabel = app.staticTexts["Login Label"]
		
		XCTAssertTrue(nameLabel.waitForExistence(timeout: 10), "Имя профиля не появилось")
		XCTAssertEqual(nameLabel.label, "Victor Vorobyov", "Имя в профиле не совпадает!")
		
		XCTAssertTrue(loginLabel.exists)
		XCTAssertEqual(loginLabel.label, "@viktorrr398")
		
		// When (Действие: логаут)
		let logoutButton = app.buttons["logout button"]
		XCTAssertTrue(logoutButton.exists)
		logoutButton.tap()
		
		let alert = app.alerts["Пока, пока!"]
		XCTAssertTrue(alert.waitForExistence(timeout: 5))
		alert.buttons["Да"].tap()
		
		// Then (Проверка: вернулись ли мы на экран авторизации)
		let authButton = app.buttons["Authenticate"]
		XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Не вернулись на экран Auth")
	}
}
