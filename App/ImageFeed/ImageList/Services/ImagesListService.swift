import Foundation
import CoreGraphics

final class ImagesListService {
	
	// MARK: - Properties
	static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	static let shared = ImagesListService()
	
	private(set) var photos: [Photo] = []
	private var lastLoadedPage: Int?
	private var task: URLSessionTask?
	private var likeTask: URLSessionTask?
	private static let isoDateFormatter = ISO8601DateFormatter()
	
	private init() {}
	
	// MARK: - Public Methods
	func fetchPhotosNextPage() {
		assert(Thread.isMainThread)
		if task != nil { return }
		
		if CommandLine.arguments.contains("testMode") && !photos.isEmpty {
			return
		}
		
		let nextPage = (lastLoadedPage ?? 0) + 1
		
		guard let request = makeNextPageRequest(page: nextPage) else { return }
		
		let newTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
			DispatchQueue.main.async {
				guard let self else { return }
				
				defer { self.task = nil}
				
				if let error = error {
					print("[ImagesListService.fetchPhotosNextPage]: Network-Error - \(error), Page: \(nextPage)")
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
							size: CGSize(width: result.width ?? 0, height: result.height ?? 0),
							createdAt: ImagesListService.isoDateFormatter.date(from: result.createdAt ?? ""),
							welcomeDescription: result.description,
							thumbImageURL: result.urls?.regular ?? "",
							largeImageURL: result.urls?.full ?? "",
							isLiked: result.likedByUser ?? false
						)
					}
					
					self.photos.append(contentsOf: newPhotos)
					self.lastLoadedPage = nextPage
					
					NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
					
				} catch {
					if let responseString = String(data: data, encoding: .utf8) {
						print("ОТВЕТ СЕРВЕРА: \(responseString)")
					}
					print("[ImagesListService.fetchPhotosNextPage]: Decoding-Error - \(error), Data: \(String(data: data, encoding: .utf8) ?? "")")
				}
			}
		}
		
		self.task = newTask
		newTask.resume()
	}
	
	func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
		assert(Thread.isMainThread)
		likeTask?.cancel()
		
		let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
		guard let url = URL(string: urlString) else {
			completion(.failure(NetworkError.invalidRequest))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = isLike ? "POST" : "DELETE"
		
		if let token = OAuth2TokenStorage.shared.token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		let newTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikeUpdateResult, Error>) in
			DispatchQueue.main.async {
				guard let self else { return }
				self.likeTask = nil
				
				switch result {
				case .success(let body):
					if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
						let oldPhoto = self.photos[index]
						let newPhoto = Photo(
							id: oldPhoto.id,
							size: oldPhoto.size,
							createdAt: oldPhoto.createdAt,
							welcomeDescription: oldPhoto.welcomeDescription,
							thumbImageURL: oldPhoto.thumbImageURL,
							largeImageURL: oldPhoto.largeImageURL,
							isLiked: body.photo.likedByUser ?? isLike
						)
						self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
					}
					completion(.success(()))
					
				case .failure(let error):
					print("[ImagesListService.changeLike]: Network-Error - \(error), PhotoID: \(photoId)")
					completion(.failure(error))
				}
			}
		}
		self.likeTask = newTask
		newTask.resume()
	}
	
	func clear() {
		photos = []
		lastLoadedPage = nil
		task?.cancel()
		task = nil
		likeTask?.cancel()
		likeTask = nil
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
