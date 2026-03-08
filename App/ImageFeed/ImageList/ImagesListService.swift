import Foundation
import CoreGraphics

struct PhotoResult: Decodable {
	let id: String
	let width: Int
	let height: Int
	let createdAt: String?
	let description: String?
	let urls: UrlsResult
	let likedByUser: Bool
}

struct UrlsResult: Decodable {
	let thumb: String
	let full: String
	let regular: String
}

struct Photo {
	let id: String
	let size: CGSize
	let createdAt: Date?
	let welcomeDescription: String?
	let thumbImageURL: String
	let largeImageURL: String
	let isLiked: Bool
}

final class ImagesListService {

	// MARK: - Properties
	static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	private(set) var photos: [Photo] = []
	private var lastLoadedPage: Int?
	private var task: URLSessionTask?
	private static let isoDateFormatter = ISO8601DateFormatter()
	
	// MARK: - Public Methods
	func fetchPhotosNextPage() {
		assert(Thread.isMainThread)
		if task != nil { return }
		
		let nextPage = (lastLoadedPage ?? 0) + 1
		
		guard let request = makeNextPageRequest(page: nextPage) else { return }
		
		let newTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			DispatchQueue.main.async {
				guard let self else { return }
				
				defer { self.task = nil}
				
				if let error = error {
					print("Сетевая ошибка: \(error)")
					return
				}
				
				guard let data = data else { return }
				
				do {
					let decoder = JSONDecoder()
					decoder.keyDecodingStrategy = .convertFromSnakeCase
					
					let photosResult = try decoder.decode([PhotoResult].self, from: data)
					
					let newPhotos = photosResult.map { result in
						Photo(
							id: result.id,
							size: CGSize(width: result.width, height: result.height),
							createdAt: ImagesListService.isoDateFormatter.date(from: result.createdAt ?? ""),
							welcomeDescription: result.description,
							thumbImageURL: result.urls.regular,
							largeImageURL: result.urls.full,
							isLiked: result.likedByUser
						)
					}
					
					self.photos.append(contentsOf: newPhotos)
					self.lastLoadedPage = nextPage
					
					NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
					
				} catch {
					if let responseString = String(data: data, encoding: .utf8) {
						print("ОТВЕТ СЕРВЕРА: \(responseString)")
					}
					print("Ошибка декодирования: \(error)")
				}
			}
		}
		
		self.task = newTask
		newTask.resume()
	}
	
	func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
		assert(Thread.isMainThread)
		task?.cancel()
		
		guard let url = URL(string: "https://unsplash.com\(photoId)/like") else {
			completion(.failure(NetworkError.invalidRequest))
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = isLike ? "POST" : "DELETE"
		
		if let token = OAuth2TokenStorage.shared.token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		let newTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
			guard let self else { return }
			self.task = nil
			
			switch result {
			case .success(_):
				if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
					let oldPhoto = self.photos[index]
					let newPhoto = Photo(
						id: oldPhoto.id,
						size: oldPhoto.size,
						createdAt: oldPhoto.createdAt,
						welcomeDescription: oldPhoto.welcomeDescription,
						thumbImageURL: oldPhoto.thumbImageURL,
						largeImageURL: oldPhoto.largeImageURL,
						isLiked: !oldPhoto.isLiked
					)
					self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
				}
				completion(.success(()))
				
			case .failure(let error):
				completion(.failure(error))
			}
		}
		self.task = newTask
		newTask.resume()
	}
	
	// MARK: - Private Methods
	private func makeNextPageRequest(page: Int) -> URLRequest? {
		var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")
		urlComponents?.queryItems = [
			URLQueryItem(name: "page", value: "\(page)"),
			URLQueryItem(name: "per_page", value: "10")
		]
		
		guard let url = urlComponents?.url else { return nil }
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		if let token = OAuth2TokenStorage.shared.token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		return request
	}
}

// MARK: - Extensions
extension Array {
	func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
		var array = self
		array[index] = newValue
		return array
	}
}
