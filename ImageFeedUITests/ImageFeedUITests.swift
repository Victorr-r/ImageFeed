import XCTest

class Image_FeedUITests: XCTestCase {
	private var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments.append("testMode")
		app.launch()
	}
	
	func testAuth() throws {
		let authButton = app.buttons["Authenticate"]
		XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Кнопка не найдена!")
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
		
		let tablesQuery = app.tables
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		
		XCTAssertTrue(cell.waitForExistence(timeout: 30), "Лента не загрузилась. Возможно, ошибка в запросе профиля.")
	}
	
	func testFeed() throws {
		let tablesQuery = app.tables
		let firstCell = tablesQuery.cells.element(boundBy: 0)
		XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Лента не загрузилась")
		
		let likeButton = firstCell.buttons["like button off"]
		XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
		likeButton.tap()
		
		let likeButtonOn = firstCell.buttons["like button on"]
		XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 15))
		likeButtonOn.tap()
		XCTAssertTrue(likeButton.waitForExistence(timeout: 15))
		
		firstCell.tap()
		
		let fullImage = app.images.element
		XCTAssertTrue(fullImage.waitForExistence(timeout: 35), "Фото не загрузилось")
		
		fullImage.pinch(withScale: 3, velocity: 1)
		sleep(1)
		
		fullImage.pinch(withScale: 0.5, velocity:-0.5)
		sleep(1)
		
		let navBackButton = app.buttons["nav back button white"].firstMatch
		XCTAssertTrue(navBackButton.waitForExistence(timeout: 10), "Кнопка назад не найдена")
		navBackButton.tap()
		
		XCTAssertTrue(tablesQuery.element.waitForExistence(timeout: 10))
	}
	
	func testProfile() throws {
		sleep(5)
		
		let profileTab = app.tabBars.buttons.element(boundBy: 1)
		XCTAssertTrue(profileTab.waitForExistence(timeout: 10))
		profileTab.tap()
		
		let nameLabel = app.staticTexts["Name Label"]
		let loginLabel = app.staticTexts["Login Label"]
		
		XCTAssertTrue(nameLabel.waitForExistence(timeout: 10), "Имя профиля не появилось")
		XCTAssertEqual(nameLabel.label, "Victor Vorobyov", "Имя в профиле не совпадает!")
		
		XCTAssertTrue(loginLabel.exists)
		XCTAssertEqual(loginLabel.label, "@viktorrr398")
		
		let logoutButton = app.buttons["logout button"]
		XCTAssertTrue(logoutButton.exists)
		logoutButton.tap()
		
		let alert = app.alerts["Пока, пока!"]
		XCTAssertTrue(alert.waitForExistence(timeout: 5))
		alert.buttons["Да"].tap()
		
		let authButton = app.buttons["Authenticate"]
		XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Не вернулись на экран Auth")
	}
}
